package com.wf.listener;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.TaskEventType;
import com.aizuda.bpm.engine.core.enums.TaskType;
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
import java.util.function.BiConsumer;
import java.util.stream.Collectors;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class ProcessListener {

    private final FlowLongEngine flowLongEngine;
    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;

    /**
     * 状态值映射
     */
    private static final Map<TaskEventType, Integer> STATE_VALUES =
            Collections.unmodifiableMap(new HashMap<TaskEventType, Integer>() {{
                put(TaskEventType.start, 1);
                put(TaskEventType.restart, 1);
                put(TaskEventType.revoke, 0);
                put(TaskEventType.reject, 3);
                put(TaskEventType.autoReject, 3);
                put(TaskEventType.terminate, 3);
            }});

    /**
     * 事件处理器映射，根据不同事件类型执行不同的处理逻辑
     */
    private final Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> eventHandlers = initEventHandlers();

    private Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> initEventHandlers() {
        Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> handlers = new EnumMap<>(TaskEventType.class);

        // 处理状态变更的事件
        STATE_VALUES.forEach((eventType, state) ->
                handlers.put(eventType, (event, updates) -> updates.put("state", state))
        );

        // 处理需要设置处理人的事件
        BiConsumer<TaskEvent, Map<String, Object>> setHandlerAction = this::setHandler;

        // 基础创建和分配类事件
        handlers.put(TaskEventType.create, setHandlerAction);
        handlers.put(TaskEventType.recreate, setHandlerAction);
        handlers.put(TaskEventType.reApproveCreate, setHandlerAction);
        handlers.put(TaskEventType.assignment, setHandlerAction);

        // 认领相关事件
        handlers.put(TaskEventType.claimRole, setHandlerAction);
        handlers.put(TaskEventType.claimDepartment, setHandlerAction);

        //// 跳转相关事件
        //handlers.put(TaskEventType.rejectJump, (event, updates) -> {
        //    setHandler(event, updates);
        //    handleRejectToInitiator(event, updates);
        //});

        // 驳回相关事件
        handlers.put(TaskEventType.reject, (event, updates) -> {
            handleRejectToInitiator(event, updates);
        });

        // 需要清空处理人的事件
        BiConsumer<TaskEvent, Map<String, Object>> clearHandlerAction = (event, updates) ->
                updates.put("handler", "");

        // 终止类事件
        handlers.put(TaskEventType.terminate, mergeActions(handlers.get(TaskEventType.terminate), clearHandlerAction));
        handlers.put(TaskEventType.revoke, mergeActions(handlers.get(TaskEventType.revoke), clearHandlerAction));

        // 委派和唤醒任务
        handlers.put(TaskEventType.delegateResolve, setHandlerAction);
        handlers.put(TaskEventType.resume, setHandlerAction);

        // 任务加签、减签可能改变处理人
        handlers.put(TaskEventType.addTaskActor, setHandlerAction);
        handlers.put(TaskEventType.removeTaskActor, setHandlerAction);

        // 撤回指定任务
        handlers.put(TaskEventType.withdraw, clearHandlerAction);

        // 处理完成事件
        handlers.put(TaskEventType.complete, this::handleCompleteEvent);
        handlers.put(TaskEventType.autoComplete, this::handleCompleteEvent);

        // 各种跳转事件
        handlers.put(TaskEventType.jump, setHandlerAction);
        handlers.put(TaskEventType.autoJump, setHandlerAction);
        handlers.put(TaskEventType.routeJump, setHandlerAction);
        handlers.put(TaskEventType.reApproveJump, setHandlerAction);

        // 结束事件
        handlers.put(TaskEventType.end, (event, updates) -> {
            updates.put("state", 2); // 设置为已完成状态
            updates.put("handler", ""); // 清空处理人
        });

        return handlers;
    }

    /**
     * 合并两个操作
     */
    private BiConsumer<TaskEvent, Map<String, Object>> mergeActions(
            BiConsumer<TaskEvent, Map<String, Object>> action1,
            BiConsumer<TaskEvent, Map<String, Object>> action2) {
        return (event, updates) -> {
            if (action1 != null) action1.accept(event, updates);
            if (action2 != null) action2.accept(event, updates);
        };
    }

    @EventListener
    public void onTaskEvent(TaskEvent taskEvent) {
        try {
            FlwTask flwTask = taskEvent.getFlwTask();
            Long instanceId = flwTask.getInstanceId();
            TaskEventType eventType = taskEvent.getEventType();

            FlwInstance instance = flowLongEngine.queryService().getInstance(instanceId);
            FlwProcess process = flowLongEngine.processService().getProcessById(instance.getProcessId());

            String businessKey = instance.getBusinessKey();
            String tableName = process.getProcessType();
            String processKey = process.getProcessKey();

            log.info("处理流程[{}]处理事件[{}]表[{}]业务ID[{}]", processKey, eventType.name(), tableName, businessKey);

            Map<String, Object> updates = new HashMap<>();

            // 调用对应的事件处理器
            BiConsumer<TaskEvent, Map<String, Object>> handler = eventHandlers.get(eventType);
            if (handler != null) {
                handler.accept(taskEvent, updates);
            }

            // 执行更新
            if (!updates.isEmpty()) {
                updateTable(tableName, businessKey, updates);
            }
        } catch (Exception e) {
            log.error("流程事件处理失败", e);
        }
    }

    /**
     * 设置处理人
     */
    private void setHandler(TaskEvent event, Map<String, Object> updates) {
        String handler = event.getTaskActors().stream()
                .map(FlwTaskActor::getActorName) // 后续需要改成ID
                .collect(Collectors.joining(","));
        updates.put("handler", handler);
    }

    /**
     * 处理驳回至发起人事件
     */
    private void handleRejectToInitiator(TaskEvent event, Map<String, Object> updates) {
        FlwTask flwTask = event.getFlwTask();
        Long instanceId = flwTask.getInstanceId();

        try {
            ProcessModel processModel = flowLongEngine.queryService()
                    .getExtInstance(instanceId).model();
            NodeModel currentNode = processModel.getNode(flwTask.getTaskKey());
            if (currentNode == null) return;

            NodeModel parentNode = currentNode.getParentNode();
            if (parentNode != null && TaskType.major.eq(parentNode.getType())) {
                updates.put("state", 4);  // 驳回到发起节点状态
                updates.put("handler", "");  // 清空处理人
            }
        } catch (Exception e) {
            log.error("处理驳回至发起人事件失败", e);
        }
    }

    /**
     * 处理完成事件
     */
    private void handleCompleteEvent(TaskEvent event, Map<String, Object> updates) {
        FlwTask flwTask = event.getFlwTask();
        Long instanceId = flwTask.getInstanceId();

        try {
            ProcessModel processModel = flowLongEngine.queryService()
                    .getExtInstance(instanceId).model();

            List<NodeModel> nextChildNodes = ModelHelper.getNextChildNodes(
                    flowLongEngine.getContext(),
                    new Execution(FlowCreator.of(flwTask.getCreateId(), flwTask.getCreateBy(),
                            flwTask.getCreateBy()), null),
                    processModel.getNodeConfig(),
                    flwTask.getTaskKey()
            );

            Optional<List<FlwTask>> activeTaskList = flowLongEngine.queryService()
                    .getActiveTasksByInstanceId(instanceId)
                    .filter(ObjectUtils::isNotEmpty);

            // 仅在最终步骤设置状态为2
            if (isFinalStep(nextChildNodes) && !activeTaskList.isPresent()) {
                updates.put("state", 2);  // 审批通过状态
                updates.put("handler", "");  // 清空处理人
            }
        } catch (Exception e) {
            log.error("处理完成事件失败", e);
        }
    }

    /**
     * 判断是否是最终步骤
     */
    private boolean isFinalStep(List<NodeModel> nextNodes) {
        return nextNodes.isEmpty() ||
                nextNodes.stream().noneMatch(ModelHelper::checkExistApprovalNode);
    }

    /**
     * 更新表数据
     */
    private void updateTable(String tableName, String businessKey, Map<String, Object> updates) {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            String pkColumn = getPrimaryKeyColumn(metaData, tableName);
            String sql = buildUpdateSql(tableName, pkColumn, updates);
            List<Object> params = new ArrayList<>(updates.values());
            params.add(businessKey);
            jdbcTemplate.update(sql, params.toArray());
            log.info("执行的SQL: {}", sql);
            log.info("执行的参数: {}", params);
        } catch (SQLException e) {
            log.error("获取表元数据失败", e);
        }
    }

    /**
     * 获取表的主键列名
     */
    private String getPrimaryKeyColumn(DatabaseMetaData metaData, String tableName) throws SQLException {
        try (ResultSet rs = metaData.getPrimaryKeys(null, null, tableName)) {
            if (rs.next()) {
                return rs.getString("COLUMN_NAME");
            }
            throw new RuntimeException("表" + tableName + "未找到主键列");
        }
    }

    /**
     * 构建更新SQL语句
     */
    private String buildUpdateSql(String tableName, String pkColumn, Map<String, Object> updates) {
        String setClause = updates.keySet().stream()
                .map(col -> col + " = ?")
                .collect(Collectors.joining(", "));
        return String.format("UPDATE %s SET %s WHERE %s = ?", tableName, setClause, pkColumn);
    }
}