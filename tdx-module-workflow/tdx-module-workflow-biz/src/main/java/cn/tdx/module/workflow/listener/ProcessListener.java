package cn.tdx.module.workflow.listener;

import cn.qhdl.framework.security.core.util.SecurityFrameworkUtils;
import cn.qhdl.framework.tenant.core.context.TenantContextHolder;
import cn.qhdl.module.system.api.dept.DeptApi;
import cn.qhdl.module.system.api.mail.MailSendApi;
import cn.qhdl.module.system.api.mail.dto.MailSendSingleToUserReqDTO;
import cn.qhdl.module.system.api.notify.NotifyMessageSendApi;
import cn.qhdl.module.system.api.notify.dto.NotifySendSingleToUserReqDTO;
import cn.qhdl.module.system.api.user.AdminUserApi;
import cn.qhdl.module.system.api.user.dto.AdminUserRespDTO;
import cn.qhdl.module.workflow.dal.NotificationInfo;
import cn.qhdl.module.workflow.dal.ProcessContext;
import cn.qhdl.module.workflow.service.impl.RedisService;
import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.*;
import com.aizuda.bpm.engine.entity.*;
import com.aizuda.bpm.engine.model.*;
import com.aizuda.bpm.mybatisplus.mapper.FlwExtInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwTaskMapper;
import com.aizuda.bpm.spring.event.TaskEvent;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.EnableAsync;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.BiConsumer;
import java.util.stream.Collectors;

@EnableAsync
@Configuration
@RequiredArgsConstructor
@Slf4j
public class ProcessListener {

    /**
     * 状态值映射
     */
    private static final Map<TaskEventType, Integer> STATE_VALUES = initStateValues();
    private static final Map<TaskEventType, String> TASK_COUNT_CATEGORY = initTaskCountCategory();
    private static final Map<TaskEventType, String> NOTIFY_TEMPLATE_MAPPING = initNotifyTemplateMapping();
    private final FlowLongEngine flowLongEngine;
    private final JdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private final FlwTaskMapper flwTaskMapper;
    private final FlwHisInstanceMapper flwHisInstanceMapper;
    private final FlwExtInstanceMapper flwExtInstanceMapper;
    private final RedisService redisService;
    private final AdminUserApi adminUserApi;
    private final DeptApi deptApi;
    private final NotifyMessageSendApi notifySendApi;
    private final MailSendApi mailSendApi;

    /**
     * 事件处理器映射
     */
    private final Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> eventHandlers = initEventHandlers();

    private static Map<TaskEventType, Integer> initStateValues() {
        Map<TaskEventType, Integer> stateValues = new EnumMap<>(TaskEventType.class);
        stateValues.put(TaskEventType.start, 1);
        stateValues.put(TaskEventType.restart, 1);
        stateValues.put(TaskEventType.revoke, 0);
        stateValues.put(TaskEventType.reject, 3);
        stateValues.put(TaskEventType.autoReject, 3);
        stateValues.put(TaskEventType.terminate, 3);
        stateValues.put(TaskEventType.timeout, 3);
        return Collections.unmodifiableMap(stateValues);
    }

    private static Map<TaskEventType, String> initTaskCountCategory() {
        Map<TaskEventType, String> category = new EnumMap<>(TaskEventType.class);

        // 发起类 -> submit
        category.put(TaskEventType.start, "submit");
        category.put(TaskEventType.startAsDraft, "submit");
        category.put(TaskEventType.restart, "submit");

        // 已处理类 -> done
        category.put(TaskEventType.complete, "done");
        category.put(TaskEventType.delegateResolve, "done");
        category.put(TaskEventType.addTaskActor, "done");
        category.put(TaskEventType.removeTaskActor, "done");
        category.put(TaskEventType.reject, "done");
        category.put(TaskEventType.reclaim, "done");
        category.put(TaskEventType.withdraw, "done");
        category.put(TaskEventType.resume, "done");
        category.put(TaskEventType.revoke, "done");
        category.put(TaskEventType.terminate, "done");
        category.put(TaskEventType.timeout, "done");
        category.put(TaskEventType.jump, "done");
        category.put(TaskEventType.autoJump, "done");
        category.put(TaskEventType.rejectJump, "done");
        category.put(TaskEventType.routeJump, "done");
        category.put(TaskEventType.reApproveJump, "done");
        category.put(TaskEventType.autoComplete, "done");
        category.put(TaskEventType.autoReject, "done");
        category.put(TaskEventType.end, "done");

        // 抄送类 -> about
        category.put(TaskEventType.cc, "about");
        category.put(TaskEventType.createCc, "about");

        return Collections.unmodifiableMap(category);
    }

    private static Map<TaskEventType, String> initNotifyTemplateMapping() {
        Map<TaskEventType, String> mapping = new EnumMap<>(TaskEventType.class);

        // 新的审批任务
        mapping.put(TaskEventType.create, "flow-task");
        mapping.put(TaskEventType.reApproveCreate, "flow-task");
        mapping.put(TaskEventType.assignment, "flow-task");

        // 审批通过
        mapping.put(TaskEventType.complete, "flow-complete");
        mapping.put(TaskEventType.autoComplete, "flow-complete");

        // 驳回
        mapping.put(TaskEventType.reject, "flow-reject");
        mapping.put(TaskEventType.autoReject, "flow-reject");

        // 转交
        mapping.put(TaskEventType.delegateResolve, "flow-transfer");

        // 超时
        mapping.put(TaskEventType.timeout, "flow-timeout");

        // 抄送
        mapping.put(TaskEventType.cc, "flow-cc");
        mapping.put(TaskEventType.createCc, "flow-cc");

        return Collections.unmodifiableMap(mapping);
    }

    @Async
    @EventListener
    public void onTaskEvent(TaskEvent taskEvent) {
        try {
            if (TaskEventType.update.eq(taskEvent.getEventType())) {
                return;
            }

            TenantContextHolder.setIgnore(false);

            FlwTask flwTask = taskEvent.getFlwTask();
            TaskEventType eventType = taskEvent.getEventType();

            ProcessContext context = buildProcessContext(flwTask);

            log.info("任务处理流程[{}]处理事件[{}]表[{}]业务ID[{}]",
                    context.getProcessKey(), eventType.name(), context.getTableName(), context.getBusinessKey());

            // 处理业务逻辑
            handleBusinessLogic(taskEvent, context);

            // 处理变量设置
            handleVariableSettings(taskEvent, context);

            // 统计任务数量
            updateUserTaskCount(taskEvent);

            // 发送通知消息
            sendNotificationMessage(taskEvent, context);

        } catch (Exception e) {
            log.error("流程事件处理失败", e);
        }
    }

    /**
     * 构建流程上下文
     */
    private ProcessContext buildProcessContext(FlwTask flwTask) {
        Long instanceId = flwTask.getInstanceId();
        FlwInstance instance = flowLongEngine.queryService().getInstance(instanceId);
        FlwProcess process = flowLongEngine.processService().getProcessById(instance.getProcessId());

        String businessKey = instance.getBusinessKey();
        if (ObjectUtils.isEmpty(businessKey)) {
            FlwHisInstance hisInstance = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                    .select(FlwHisInstance::getBusinessKey)
                    .eq(FlwHisInstance::getId, instance.getParentInstanceId())
                    .last("limit 1")
                    .one();
            businessKey = hisInstance != null ? hisInstance.getBusinessKey() : null;
        }

        return ProcessContext.builder()
                .instanceId(instanceId)
                .businessKey(businessKey)
                .tableName(process.getProcessType())
                .processKey(process.getProcessKey())
                .processName(process.getProcessName())
                .build();
    }

    /**
     * 处理业务逻辑
     */
    private void handleBusinessLogic(TaskEvent taskEvent, ProcessContext context) {
        TaskEventType eventType = taskEvent.getEventType();
        Map<String, Object> updates = new HashMap<>();

        BiConsumer<TaskEvent, Map<String, Object>> handler = eventHandlers.get(eventType);
        if (handler != null) {
            handler.accept(taskEvent, updates);
        }

        if (!updates.isEmpty()) {
            updateTable(context.getTableName(), context.getBusinessKey(), updates);
        }

        if (updates.containsKey("state") && updates.get("state").equals(2)) {
            context.setIsFinished(true);
        }
    }

    /**
     * 处理变量设置
     */
    private void handleVariableSettings(TaskEvent taskEvent, ProcessContext context) {
        if (!TaskEventType.create.eq(taskEvent.getEventType())) {
            return;
        }

        try {
            FlwTask flwTask = taskEvent.getFlwTask();
            Optional<NodeModel> nextNodeOpt = Optional.ofNullable(flowLongEngine.queryService()
                    .getExtInstance(context.getInstanceId())
                    .model()
                    .getNode(flwTask.getTaskKey())
                    .getChildNode());

            if (!nextNodeOpt.isPresent()) {
                return;
            }

            NodeModel nodeModel = nextNodeOpt.get();
            List<ConditionNode> conditionNodes = getConditionNodes(nodeModel);

            if (ObjectUtils.isNotEmpty(conditionNodes)) {
                Map<String, Object> fields = extractFieldsFromConditions(conditionNodes);
                if (!fields.isEmpty()) {
                    Map<String, Object> variables = queryTable(context.getTableName(), context.getBusinessKey(), fields);
                    if (variables != null && !variables.isEmpty()) {
                        flowLongEngine.runtimeService().addVariable(context.getInstanceId(), variables);
                    }
                }
            }
        } catch (Exception e) {
            log.error("处理变量设置失败", e);
        }
    }

    /**
     * 获取条件节点列表
     */
    private List<ConditionNode> getConditionNodes(NodeModel nodeModel) {
        if (nodeModel.conditionNode()) {
            return nodeModel.getConditionNodes();
        } else if (nodeModel.parallelNode()) {
            return nodeModel.getParallelNodes();
        } else if (nodeModel.inclusiveNode()) {
            return nodeModel.getInclusiveNodes();
        } else if (nodeModel.routeNode()) {
            return nodeModel.getRouteNodes();
        }
        return Collections.emptyList();
    }

    /**
     * 从条件中提取字段
     */
    private Map<String, Object> extractFieldsFromConditions(List<ConditionNode> conditionNodes) {
        return conditionNodes.stream()
                .filter(ObjectUtils::isNotEmpty)
                .flatMap(node -> Optional.ofNullable(node.getConditionList())
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
    }

    /**
     * 发送通知消息
     */
    private void sendNotificationMessage(TaskEvent taskEvent, ProcessContext context) {
        try {
            TaskEventType eventType = taskEvent.getEventType();
            String templateCode = NOTIFY_TEMPLATE_MAPPING.get(eventType);

            if (templateCode == null) {
                return;
            }

            NotificationInfo notificationInfo = buildNotificationInfo(taskEvent, context, templateCode);
            if (notificationInfo != null && !notificationInfo.getReceiverIds().isEmpty()) {
                log.info("通知对应的事件: 事件[{}], 模板[{}]", taskEvent.getEventType().name(), notificationInfo.getTemplateCode());
                sendNotification(notificationInfo);
            }
        } catch (Exception e) {
            log.error("发送通知消息失败", e);
        }
    }

    /**
     * 构建通知信息
     */
    private NotificationInfo buildNotificationInfo(TaskEvent taskEvent, ProcessContext context, String templateCode) {
        TaskEventType eventType = taskEvent.getEventType();
        Map<String, Object> templateParams = new HashMap<>();
        Set<Long> receiverIds = new HashSet<>();

        // 根据不同事件类型构建通知信息
        switch (eventType) {
            case create:
            case reApproveCreate:
            case assignment:
                // 新任务通知处理人
                templateParams.put("userName", getInitiatorName(taskEvent));
                templateParams.put("processName", context.getProcessName());
                receiverIds.addAll(getTaskActorIds(taskEvent));
                break;

            case complete:
            case autoComplete:
                // 流程真正结束时通知发起人
                if (context.getIsFinished()) {
                    templateParams.put("processName", context.getProcessName());
                    receiverIds.add(Long.valueOf(taskEvent.getFlowCreator().getCreateId()));
                }
                break;

            case reject:
            case autoReject:
                // 驳回通知发起人
                templateParams.put("processName", context.getProcessName());
                receiverIds.add(Long.valueOf(taskEvent.getFlowCreator().getCreateId()));
                break;

            case delegateResolve:
                // 转交通知新处理人
                templateParams.put("userName", getCurrentUserName());
                receiverIds.addAll(getTaskActorIds(taskEvent));
                break;

            case timeout:
                // 超时通知处理人
                templateParams.put("processName", context.getProcessName());
                receiverIds.addAll(getTaskActorIds(taskEvent));
                break;

            case cc:
            case createCc:
                // 抄送通知抄送人
                templateParams.put("processName", context.getProcessName());
                receiverIds.addAll(getTaskActorIds(taskEvent));
                break;

            default:
                return null;
        }

        if (receiverIds.isEmpty()) {
            return null;
        }

        return NotificationInfo.builder()
                .templateCode(templateCode)
                .templateParams(templateParams)
                .receiverIds(receiverIds)
                .build();
    }


    /**
     * 发送通知
     */
    private void sendNotification(NotificationInfo notificationInfo) {
        for (Long receiverId : notificationInfo.getReceiverIds()) {
            try {
                NotifySendSingleToUserReqDTO notifyRequest = new NotifySendSingleToUserReqDTO()
                        .setUserId(receiverId)
                        .setTemplateCode(notificationInfo.getTemplateCode())
                        .setTemplateParams(notificationInfo.getTemplateParams());

                notifySendApi.sendSingleMessageToAdmin(notifyRequest);

                MailSendSingleToUserReqDTO mailRequest = new MailSendSingleToUserReqDTO()
                        .setUserId(receiverId)
                        .setTemplateCode(notificationInfo.getTemplateCode())
                        .setTemplateParams(notificationInfo.getTemplateParams());

                mailSendApi.sendSingleMailToAdmin(mailRequest);

                log.info("发送通知成功: 用户[{}], 模板[{}]", receiverId, notificationInfo.getTemplateCode());
            } catch (Exception e) {
                log.error("发送通知失败: 用户[{}], 模板[{}]", receiverId, notificationInfo.getTemplateCode(), e);
            }
        }
    }

    /**
     * 获取发起人姓名
     */
    private String getInitiatorName(TaskEvent taskEvent) {
        try {
            Long initiatorId = Long.valueOf(taskEvent.getFlowCreator().getCreateId());
            AdminUserRespDTO user = adminUserApi.getUser(initiatorId);
            return user != null ? user.getNickname() : "未知用户";
        } catch (Exception e) {
            log.error("获取发起人姓名失败", e);
            return "未知用户";
        }
    }

    /**
     * 获取当前用户姓名
     */
    private String getCurrentUserName() {
        try {
            return SecurityFrameworkUtils.getLoginUserNickname();
        } catch (Exception e) {
            log.error("获取当前用户姓名失败", e);
            return "未知用户";
        }
    }

    /**
     * 获取任务处理人ID列表
     */
    private Set<Long> getTaskActorIds(TaskEvent taskEvent) {
        return Optional.ofNullable(taskEvent.getTaskActors())
                .orElse(Arrays.asList(FlwTaskActor.ofFlwTask(taskEvent.getFlwTask())))
                .stream()
                .map(FlwTaskActor::getActorId)
                .map(Long::valueOf)
                .collect(Collectors.toSet());
    }

    private Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> initEventHandlers() {
        Map<TaskEventType, BiConsumer<TaskEvent, Map<String, Object>>> handlers = new EnumMap<>(TaskEventType.class);

        // 处理状态变更的事件
        STATE_VALUES.forEach((eventType, state) ->
                handlers.put(eventType, (event, updates) -> updates.put("state", state))
        );

        // 处理需要设置处理人的事件
        BiConsumer<TaskEvent, Map<String, Object>> setHandlerAction = this::setHandler;

        handlers.put(TaskEventType.create, setHandlerAction);
        handlers.put(TaskEventType.recreate, setHandlerAction);
        handlers.put(TaskEventType.reApproveCreate, setHandlerAction);
        handlers.put(TaskEventType.assignment, setHandlerAction);
        handlers.put(TaskEventType.claimRole, setHandlerAction);
        handlers.put(TaskEventType.claimDepartment, setHandlerAction);
        handlers.put(TaskEventType.delegateResolve, setHandlerAction);
        handlers.put(TaskEventType.resume, setHandlerAction);
        handlers.put(TaskEventType.addTaskActor, setHandlerAction);
        handlers.put(TaskEventType.removeTaskActor, setHandlerAction);
        handlers.put(TaskEventType.jump, setHandlerAction);
        handlers.put(TaskEventType.routeJump, setHandlerAction);
        handlers.put(TaskEventType.reApproveJump, setHandlerAction);

        // 处理驳回事件
        handlers.put(TaskEventType.reject, this::handleRejectEvent);
        handlers.put(TaskEventType.autoReject, this::handleRejectEvent);

        // 需要清空处理人的事件
        BiConsumer<TaskEvent, Map<String, Object>> clearHandlerAction = (event, updates) ->
                updates.put("handler", "");

        handlers.put(TaskEventType.terminate, mergeActions(handlers.get(TaskEventType.terminate), clearHandlerAction));
        handlers.put(TaskEventType.timeout, mergeActions(handlers.get(TaskEventType.terminate), clearHandlerAction));
        handlers.put(TaskEventType.revoke, mergeActions(handlers.get(TaskEventType.revoke), clearHandlerAction));
        handlers.put(TaskEventType.withdraw, clearHandlerAction);

        // 处理完成事件
        handlers.put(TaskEventType.autoComplete, this::handleCompleteEvent);
        handlers.put(TaskEventType.complete, this::handleCompleteEvent);

        // 结束事件
        handlers.put(TaskEventType.end, (event, updates) -> {
            updates.put("state", 2);
            updates.put("handler", "");
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

    /**
     * 设置处理人
     */
    private void setHandler(TaskEvent event, Map<String, Object> updates) {
        String handler = Optional.ofNullable(event.getTaskActors())
                .orElse(Arrays.asList(FlwTaskActor.ofFlwTask(event.getFlwTask())))
                .stream()
                .map(FlwTaskActor::getActorName)
                .collect(Collectors.joining(","));
        updates.put("handler", handler);

        // 设置活跃状态
        if (InstanceState.active.eq(flowLongEngine.queryService()
                .getHistInstance(event.getFlwTask().getInstanceId()).getInstanceState())) {
            updates.put("state", 1);
        }

        // 处理节点特殊逻辑
        handleNodeSpecialLogic(event);
    }

    /**
     * 处理节点特殊逻辑（自动跳过、转交等）
     */
    private void handleNodeSpecialLogic(TaskEvent event) {
        Optional.ofNullable(event.getNodeModel()).ifPresent(nodeModel -> {
            // 设置提醒时间
            if (nodeModel.getRemind()) {
                event.getFlwTask().setRemindTime(new Date());
                flwTaskMapper.updateById(event.getFlwTask());
            }

            // 处理审批人与提交人相同的情况
            if (NodeApproveSelf.initiatorThemselves.ne(nodeModel.getApproveSelf())) {
                handleSameApproveLogic(event, nodeModel);
            }
        });
    }

    /**
     * 处理审批人与提交人相同的逻辑
     */
    private void handleSameApproveLogic(TaskEvent event, NodeModel nodeModel) {
        boolean isSameUser = event.getTaskActors().stream()
                .anyMatch(actor -> Objects.equals(actor.getActorId(), event.getFlowCreator().getCreateId()));

        if (!isSameUser) {
            return;
        }

        try {
            if (NodeApproveSelf.AutoSkip.eq(nodeModel.getApproveSelf())) {
                // 自动跳过
                flowLongEngine.autoJumpTask(event.getFlwTask().getId(), event.getFlowCreator());
            } else if (NodeApproveSelf.TransferDirectSuperior.eq(nodeModel.getApproveSelf())) {
                // 转交给直接上级
                transferToDirectSuperior(event);
            } else if (NodeApproveSelf.TransferDepartmentHead.eq(nodeModel.getApproveSelf())) {
                // 转交给部门负责人
                transferToDepartmentHead(event);
            }
        } catch (Exception e) {
            log.error("处理相同审批人逻辑失败", e);
        }
    }

    /**
     * 转交给直接上级
     */
    private void transferToDirectSuperior(TaskEvent event) {
        try {
            AdminUserRespDTO leader = adminUserApi.getNthLevelLeader(
                    Long.valueOf(event.getFlowCreator().getCreateId()), 1);
            if (leader != null) {
                flowLongEngine.taskService().transferTask(
                        event.getFlwTask().getId(),
                        getFlowCreator(),
                        FlowCreator.of(leader.getId().toString(), leader.getNickname())
                );
            }
        } catch (Exception e) {
            log.error("转交给直接上级失败", e);
        }
    }

    /**
     * 转交给部门负责人
     */
    private void transferToDepartmentHead(TaskEvent event) {
        try {
            Long userId = Long.valueOf(event.getFlowCreator().getCreateId());
            AdminUserRespDTO user = adminUserApi.getUser(userId);
            if (user != null && user.getDeptId() != null) {
                Long leaderUserId = deptApi.getDept(user.getDeptId()).getLeaderUserId();
                if (leaderUserId != null) {
                    String nickname = adminUserApi.getUser(leaderUserId).getNickname();
                    flowLongEngine.taskService().transferTask(
                            event.getFlwTask().getId(),
                            getFlowCreator(),
                            FlowCreator.of(leaderUserId.toString(), nickname)
                    );
                }
            }
        } catch (Exception e) {
            log.error("转交给部门负责人失败", e);
        }
    }

    private FlowCreator getFlowCreator() {
        return FlowCreator.of(
                SecurityFrameworkUtils.getLoginUserId().toString(),
                SecurityFrameworkUtils.getLoginUserNickname()
        );
    }

    /**
     * 处理驳回事件
     */
    private void handleRejectEvent(TaskEvent event, Map<String, Object> updates) {
        // 设置基本的驳回状态
        updates.put("state", 3);

        try {
            FlwTask flwTask = event.getFlwTask();
            Long instanceId = flwTask.getInstanceId();

            ProcessModel processModel = flowLongEngine.queryService()
                    .getExtInstance(instanceId).model();
            NodeModel currentNode = processModel.getNode(flwTask.getTaskKey());

            if (currentNode != null) {
                NodeModel parentNode = currentNode.getParentNode();
                if (parentNode != null && parentNode.conditionNode()) {
                    parentNode = parentNode.getParentNode();
                }

                // 如果驳回到发起节点
                if (parentNode != null && TaskType.major.eq(parentNode.getType())) {
                    updates.put("state", 4);  // 驳回到发起节点状态
                }
            }

            updates.put("handler", "");  // 清空处理人
        } catch (Exception e) {
            log.error("处理驳回事件失败", e);
        }
    }

    /**
     * 处理完成事件
     */
    private void handleCompleteEvent(TaskEvent event, Map<String, Object> updates) {
        try {
            // 仅在最终步骤设置状态为2
            if (isFinalStep(event)) {
                updates.put("state", 2);  // 审批通过状态
                updates.put("handler", "");  // 清空处理人
            }
        } catch (Exception e) {
            log.error("处理完成事件失败", e);
        }
    }

    /**
     * 判断是否是流程的最终完成节点
     */
    private boolean isFinalStep(TaskEvent event) {
        try {
            FlwTask flwTask = event.getFlwTask();
            Long instanceId = flwTask.getInstanceId();

            ProcessModel processModel = flowLongEngine.queryService()
                    .getExtInstance(instanceId).model();

            Optional<NodeModel> nextNode = processModel
                    .getNode(flwTask.getTaskKey())
                    .nextNode()
                    .filter(ObjectUtils::isNotEmpty);

            List<FlwTask> activeTasks = flowLongEngine.queryService()
                    .getActiveTasksByInstanceId(instanceId)
                    .orElse(Collections.emptyList());

            return (!nextNode.isPresent() || !ModelHelper.checkExistApprovalNode(nextNode.get()))
                    && activeTasks.isEmpty();
        } catch (Exception e) {
            log.error("判断流程是否已最终完成失败", e);
            return false;
        }
    }

    /**
     * 更新用户任务统计
     */
    private void updateUserTaskCount(TaskEvent event) {
        TaskEventType eventType = event.getEventType();
        String category = TASK_COUNT_CATEGORY.get(eventType);
        if (category == null) {
            return;
        }

        String redisKey = "wf:count:" + category;
        AtomicInteger increment = new AtomicInteger(1);

        try {
            switch (category) {
                case "submit":
                case "about":
                    event.getTaskActors().forEach(actor -> {
                        redisService.incrementZSetScore(redisKey, Long.valueOf(actor.getActorId()), increment.get());
                        increment.getAndIncrement();
                    });
                    break;
                case "done":
                    redisService.incrementZSetScore(redisKey, Long.valueOf(event.getFlowCreator().getCreateId()), increment.get());
                    break;
            }
        } catch (Exception e) {
            log.error("更新用户任务统计失败", e);
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