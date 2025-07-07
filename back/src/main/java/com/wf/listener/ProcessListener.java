package com.wf.listener;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.enums.InstanceState;
import com.aizuda.bpm.engine.core.enums.NodeApproveSelf;
import com.aizuda.bpm.engine.core.enums.TaskEventType;
import com.aizuda.bpm.engine.core.enums.TaskType;
import com.aizuda.bpm.engine.entity.*;
import com.aizuda.bpm.engine.model.*;
import com.aizuda.bpm.mybatisplus.mapper.FlwExtInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwTaskMapper;
import com.aizuda.bpm.spring.event.TaskEvent;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.wf.utils.RedisService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.jdbc.core.JdbcTemplate;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.BiConsumer;
import java.util.stream.Collectors;


@Configuration
@RequiredArgsConstructor
@Slf4j
public class ProcessListener {

    /**
     * 状态值映射
     */
    private static final Map<TaskEventType, Integer> STATE_VALUES =
            Collections.unmodifiableMap(new HashMap<TaskEventType, Integer>() {{
                put(TaskEventType.start, 1);
                put(TaskEventType.restart, 1);
                put(TaskEventType.revoke, 0);
                put(TaskEventType.autoComplete, 2);
                put(TaskEventType.reject, 3);
                put(TaskEventType.autoReject, 3);
                put(TaskEventType.terminate, 3);
            }});
    private static final Map<TaskEventType, String> TASK_COUNT_CATEGORY = new EnumMap<>(TaskEventType.class);

    static {
        // 发起类 -> submit
        TASK_COUNT_CATEGORY.put(TaskEventType.start, "submit");
        TASK_COUNT_CATEGORY.put(TaskEventType.startAsDraft, "submit");
        TASK_COUNT_CATEGORY.put(TaskEventType.restart, "submit");

        // 已处理类 -> done
        TASK_COUNT_CATEGORY.put(TaskEventType.complete, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.delegateResolve, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.addTaskActor, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.removeTaskActor, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.reject, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.reclaim, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.withdraw, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.resume, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.revoke, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.terminate, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.timeout, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.jump, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.autoJump, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.rejectJump, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.routeJump, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.reApproveJump, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.autoComplete, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.autoReject, "done");
        TASK_COUNT_CATEGORY.put(TaskEventType.end, "done");

        // 抄送类 -> about
        TASK_COUNT_CATEGORY.put(TaskEventType.cc, "about");
        TASK_COUNT_CATEGORY.put(TaskEventType.createCc, "about");
    }

    private final FlowLongEngine flowLongEngine;
    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private final FlwTaskMapper flwTaskMapper;
    private final FlwHisInstanceMapper flwHisInstanceMapper;
    private final FlwExtInstanceMapper flwExtInstanceMapper;
    private final RedisService redisService;

    /**
     * 事件处理器映射，根据不同事件类型执行不同的处理逻辑
     */
    private final Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> eventHandlers = initEventHandlers();

    public static JSONObject findNodeConfig(JSONObject root, String processId) {
        JSONObject result = new JSONObject();
        findNodeConfigRecursive(root, processId, result);
        return result;
    }

    private static void findNodeConfigRecursive(JSONObject node, String processId, JSONObject result) {
        if (node == null) return;

        // 检查当前节点是否符合条件
        if (node.getIntValue("type") == 5) {
            String callProcess = node.getString("callProcess");
            if (callProcess != null && callProcess.startsWith(processId + ":")) {
                JSONObject config = node.getJSONObject("nodeConfig");
                if (config != null) {
                    result.putAll(config);
                    return; // 找到后直接返回，如果需找多个可以改为收集到List
                }
            }
        }

        // 递归检查子节点
        JSONObject childNode = node.getJSONObject("childNode");
        if (childNode != null) {
            findNodeConfigRecursive(childNode, processId, result);
        }
    }

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
        handlers.put(TaskEventType.autoReject, mergeActions(handlers.get(TaskEventType.autoReject), clearHandlerAction));
        handlers.put(TaskEventType.revoke, mergeActions(handlers.get(TaskEventType.revoke), clearHandlerAction));

        // 自动完成
        handlers.put(TaskEventType.autoComplete, mergeActions(handlers.get(TaskEventType.autoComplete), clearHandlerAction));

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

        // 各种跳转事件
        handlers.put(TaskEventType.jump, setHandlerAction);
        //handlers.put(TaskEventType.autoJump, setHandlerAction);
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
            if (taskEvent.getEventType().eq(TaskEventType.update)) {
                return;
            }
            FlwTask flwTask = taskEvent.getFlwTask();
            Long instanceId = flwTask.getInstanceId();
            TaskEventType eventType = taskEvent.getEventType();

            FlwInstance instance = flowLongEngine.queryService().getInstance(instanceId);
            FlwProcess process = flowLongEngine.processService().getProcessById(instance.getProcessId());

            String businessKey = instance.getBusinessKey();
            if (ObjectUtils.isEmpty(businessKey)) {
                businessKey = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                        .select(FlwHisInstance::getBusinessKey)
                        .eq(FlwHisInstance::getId, instance.getParentInstanceId())
                        .last("limit 1")
                        .one().getBusinessKey();
                //if(TaskEventType.start.eq(eventType)) {
                //    String modelContent = ChainWrappers.lambdaQueryChain(flwExtInstanceMapper)
                //            .select(FlwExtInstance::getModelContent)
                //            .eq(FlwExtInstance::getId, instance.getParentInstanceId())
                //            .last("limit 1")
                //            .one().getModelContent();
                //    JSONObject root = JSON.parseObject(modelContent);
                //    JSONObject nodeConfig = findNodeConfig(root.getJSONObject("nodeConfig"), instance.getProcessId().toString());
                //    JSONObject model = JSON.parseObject(process.getModelContent());
                //    model.put("nodeConfig", nodeConfig);
                //    ChainWrappers.lambdaUpdateChain(flwExtInstanceMapper)
                //            .set(FlwExtInstance::getModelContent, model.toJSONString())
                //            .eq(FlwExtInstance::getId, instanceId)
                //            .update();
                //}
            }
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

            updateUserTaskCount(taskEvent);

            if (TaskEventType.create.eq(eventType)) {
                Optional<NodeModel> optional = Optional.ofNullable(flowLongEngine.queryService()
                        .getExtInstance(instanceId)
                        .model()
                        .getNode(flwTask.getTaskKey())
                        .getChildNode());
                if (optional.isPresent()) {
                    boolean isConditionNode = optional.get().conditionNode();
                    if (isConditionNode) {
                        Map<String, Object> collect = optional.get().getConditionNodes().stream()
                                .filter(ObjectUtils::isNotEmpty)
                                .flatMap(conditionNode -> Optional.ofNullable(conditionNode.getConditionList())
                                        .orElse(Collections.emptyList())
                                        .stream()
                                        .flatMap(innerList -> Optional.ofNullable(innerList)
                                                .orElse(Collections.emptyList())
                                                .stream()))
                                .filter(ObjectUtils::isNotEmpty)
                                .map(NodeExpression::getField)
                                .filter(ObjectUtils::isNotEmpty)
                                .collect(Collectors.toMap(
                                        field -> field,
                                        field -> 0,
                                        (v1, v2) -> v1
                                ));

                        Map<String, Object> variable = queryTable(tableName, businessKey, collect);
                        flowLongEngine.runtimeService()
                                .addVariable(instanceId, variable);
                    }
                }
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

        if (InstanceState.active.eq(flowLongEngine.queryService()
                .getHistInstance(event.getFlwTask().getInstanceId()).getInstanceState())) {
            updates.put("state", 1);
        }
        Optional.ofNullable(event.getNodeModel())
                .ifPresent(nodeModel -> {
                    // 判断是否需要审批提醒
                    if (nodeModel.getRemind()) {
                        event.getFlwTask().setRemindTime(new Date());
                        flwTaskMapper.updateById(event.getFlwTask());
                    }

                    if (NodeApproveSelf.initiatorThemselves.ne(nodeModel.getApproveSelf())) {
                        // 判断审批人与提交人为同一人时
                        if (event.getTaskActors().stream().anyMatch(e -> Objects.equals(e.getActorId(), event.getFlowCreator().getCreateId()))) {
                            // 判断是否自动跳过
                            if (NodeApproveSelf.AutoSkip.eq(nodeModel.getApproveSelf())) {
                                flowLongEngine.autoJumpTask(event.getFlwTask().getId(), event.getFlowCreator());
                                // 转交给直接上级审批
                            } else if (NodeApproveSelf.TransferDirectSuperior.eq(nodeModel.getApproveSelf())) {

                                // 转交给部门负责人审批
                            } else if (NodeApproveSelf.TransferDepartmentHead.eq(nodeModel.getApproveSelf())) {

                            }
                        }
                    }
                });
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
            if (parentNode.conditionNode()) {
                parentNode = parentNode.getParentNode();
            }
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

            Optional<NodeModel> nextNode = processModel
                    .getNode(flwTask.getTaskKey())
                    .nextNode()
                    .filter(ObjectUtils::isNotEmpty);
            //List<NodeModel> nextChildNodes = ModelHelper.getNextChildNodes(
            //        flowLongEngine.getContext(),
            //        new Execution(FlowCreator.of(flwTask.getCreateId(), flwTask.getCreateBy(),
            //                flwTask.getCreateBy()), null),
            //        processModel.getNodeConfig(),
            //        flwTask.getTaskKey()
            //);

            Optional<List<FlwTask>> activeTaskList = flowLongEngine.queryService()
                    .getActiveTasksByInstanceId(instanceId)
                    .filter(ObjectUtils::isNotEmpty);

            // 仅在最终步骤设置状态为2
            if (isFinalStep(nextNode) && !activeTaskList.isPresent()) {
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

    private boolean isFinalStep(Optional<NodeModel> optional) {
        if (optional.isPresent()) {
            return !ModelHelper.checkExistApprovalNode(optional.get());
        }
        return true;
    }

    private void updateUserTaskCount(TaskEvent event) {
        TaskEventType eventType = event.getEventType();
        String category = TASK_COUNT_CATEGORY.get(eventType);
        if (category == null) {
            return; // 非统计类事件跳过
        }

        String redisKey = "wf:count:" + category;
        AtomicInteger num = new AtomicInteger(1);
        switch (category) {
            case "submit":
            case "about":
                event.getTaskActors().forEach(actor -> {
                    redisService.incrementZSetScore(redisKey, actor.getActorId(), num.get());
                    num.getAndIncrement();
                });
                break;
            case "done":
                redisService.incrementZSetScore(redisKey, event.getFlowCreator().getCreateId(), num.get());
                break;
        }
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

    /**
     * 查询表数据
     */
    public Map<String, Object> queryTable(String tableName, String businessKey, Map<String, Object> fields) {
        try (Connection conn = dataSource.getConnection()) {
            DatabaseMetaData metaData = conn.getMetaData();
            String pkColumn = getPrimaryKeyColumn(metaData, tableName);
            String sql = buildSelectSql(tableName, pkColumn, fields);

            // 查询数据
            Map<String, Object> result = jdbcTemplate.queryForMap(sql, businessKey);
            log.info("执行的SQL: {}", sql);
            log.info("执行的参数: [{}]", businessKey);
            log.info("查询结果: {}", result);

            return result;
        } catch (SQLException e) {
            log.error("获取表元数据失败", e);
        } catch (Exception e) {
            log.error("查询表数据失败", e);
        }
        return null;
    }

    /**
     * 构建查询SQL语句
     */
    private String buildSelectSql(String tableName, String pkColumn, Map<String, Object> fields) {
        String selectClause = String.join(", ", fields.keySet());
        return String.format("SELECT %s FROM %s WHERE %s = ?", selectClause, tableName, pkColumn);
    }
}