package com.wf.listener;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.TaskEventType;
import com.aizuda.bpm.engine.entity.FlwInstance;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.engine.entity.FlwTask;
import com.aizuda.bpm.engine.entity.FlwTaskActor;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.aizuda.bpm.spring.event.TaskEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class ProcessListener {

    private static final Map<TaskEventType, String> STATUS_MAPPING;
    private static final Map<TaskEventType, Integer> STATUS_VALUE_MAPPING;

    static {
        // 状态字段映射配置（移除了complete事件）
        Map<TaskEventType, String> statusMap = new HashMap<>();
        statusMap.put(TaskEventType.start, "state");
        statusMap.put(TaskEventType.recreate, "state");
        statusMap.put(TaskEventType.revoke, "state");
        statusMap.put(TaskEventType.reject, "state");
        statusMap.put(TaskEventType.terminate, "state");
        STATUS_MAPPING = Collections.unmodifiableMap(statusMap);

        // 状态值映射配置（移除了complete事件）
        Map<TaskEventType, Integer> valueMap = new HashMap<>();
        valueMap.put(TaskEventType.start, 1);
        valueMap.put(TaskEventType.recreate, 1);
        valueMap.put(TaskEventType.revoke, 0);
        valueMap.put(TaskEventType.reject, 4);
        valueMap.put(TaskEventType.terminate, 3);
        STATUS_VALUE_MAPPING = Collections.unmodifiableMap(valueMap);
    }

    private final FlowLongEngine flowLongEngine;
    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;

    @EventListener
    public void onTaskEvent(TaskEvent taskEvent) {
        try {
            FlwTask flwTask = taskEvent.getFlwTask();
            Long instanceId = flwTask.getInstanceId();

            FlwInstance instance = flowLongEngine.queryService().getInstance(instanceId);
            FlwProcess process = flowLongEngine.processService().getProcessById(instance.getProcessId());

            String businessKey = instance.getBusinessKey();
            String tableName = process.getProcessType();
            String processKey = process.getProcessKey();

            TaskEventType eventType = taskEvent.getEventType();

            log.info("处理流程[{}]处理事件[{}]表[{}]业务ID[{}]", processKey, eventType.name(), tableName, businessKey);

            Map<String, Object> updates = new HashMap<>();

            // 处理状态字段（排除complete事件）
            if (STATUS_MAPPING.containsKey(eventType)) {
                String statusField = STATUS_MAPPING.get(eventType);
                updates.put(statusField, STATUS_VALUE_MAPPING.get(eventType));
            }

            // 处理处理人字段
            if (eventType.eq(TaskEventType.create) || eventType.eq(TaskEventType.assignment)) {
                String handler = taskEvent.getTaskActors().stream()
                        //.map(FlwTaskActor::getActorId) //后续需要改成ID
                        .map(FlwTaskActor::getActorName)
                        .collect(Collectors.joining(","));
                updates.put("handler", handler);
            }

            // 处理complete事件的状态更新
            if (eventType.eq(TaskEventType.complete)) {
                ProcessModel processModel = flowLongEngine.queryService()
                        .getExtInstance(instance.getId()).model();
                List<NodeModel> nextChildNodes = ModelHelper.getNextChildNodes(
                        flowLongEngine.getContext(),
                        new Execution(FlowCreator.of(flwTask.getCreateId(), flwTask.getCreateBy(),
                                flwTask.getCreateBy()), null),
                        processModel.getNodeConfig(),
                        flwTask.getTaskKey()
                );

                // 仅在最终步骤设置状态为2
                if (isFinalStep(nextChildNodes)) {
                    updates.put("state", 2);
                }
            }

            // 执行更新
            if (!updates.isEmpty()) {
                updateTable(tableName, businessKey, updates);
            }

        } catch (Exception e) {
            log.error("流程事件处理失败", e);
        }
    }

    // 以下方法保持不变
    private void updateTable(String tableName, String businessKey, Map<String, Object> updates) {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            String pkColumn = getPrimaryKeyColumn(metaData, tableName);
            String sql = buildUpdateSql(tableName, pkColumn, updates);
            List<Object> params = new ArrayList<>(updates.values());
            params.add(businessKey);
            jdbcTemplate.update(sql, params.toArray());
        } catch (SQLException e) {
            log.error("获取表元数据失败", e);
        }
    }

    private String getPrimaryKeyColumn(DatabaseMetaData metaData, String tableName) throws SQLException {
        try (ResultSet rs = metaData.getPrimaryKeys(null, null, tableName)) {
            if (rs.next()) {
                return rs.getString("COLUMN_NAME");
            }
            throw new RuntimeException("表" + tableName + "未找到主键列");
        }
    }

    private String buildUpdateSql(String tableName, String pkColumn, Map<String, Object> updates) {
        String setClause = updates.keySet().stream()
                .map(col -> col + " = ?")
                .collect(Collectors.joining(", "));
        return String.format("UPDATE %s SET %s WHERE %s = ?", tableName, setClause, pkColumn);
    }

    private boolean isFinalStep(List<NodeModel> nextNodes) {
        return nextNodes.isEmpty() ||
                nextNodes.stream().noneMatch(ModelHelper::checkExistApprovalNode);
    }
}