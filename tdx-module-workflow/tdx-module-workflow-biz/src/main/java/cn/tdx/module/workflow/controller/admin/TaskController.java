package cn.tdx.module.workflow.controller.admin;

import cn.tdx.framework.common.pojo.CommonResult;
import cn.tdx.framework.security.core.util.SecurityFrameworkUtils;
import cn.tdx.module.system.api.user.AdminUserApi;
import cn.tdx.module.system.api.user.dto.AdminUserRespDTO;
import cn.tdx.module.workflow.dal.*;
import cn.tdx.module.workflow.service.TaskService;
import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.TaskActorProvider;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.*;
import com.aizuda.bpm.engine.entity.*;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeAssignee;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.aizuda.bpm.mybatisplus.mapper.FlwExtInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisTaskMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwInstanceMapper;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.time.DateUtils;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("flow/task")
@RequiredArgsConstructor
public class TaskController implements TaskActorProvider {
    private final FlowLongEngine flowLongEngine;
    private final TaskService taskService;
    private final FlwInstanceMapper flwInstanceMapper;
    private final FlwHisInstanceMapper flwHisInstanceMapper;
    private final FlwExtInstanceMapper flwExtInstanceMapper;
    private final FlwHisTaskMapper flwHisTaskMapper;
    private final AdminUserApi adminUserApi;

    public static JSONObject findNodeConfig(JSONObject root, String processId) {
        JSONObject result = new JSONObject();
        findNodeConfigRecursive(root, processId, result);
        return result;
    }

    private static void findNodeConfigRecursive(JSONObject node, String processId, JSONObject result) {
        if (node == null)
            return;

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

    public static List<NodeAssignee> findAssigneesByNodeKey(JSONObject rootNode, String targetNodeKey) {
        List<NodeAssignee> result = new ArrayList<>();
        findInNode(rootNode, targetNodeKey, result);
        return result;
    }

    private static void findInNode(JSONObject node, String targetKey, List<NodeAssignee> result) {
        if (node == null || result.size() > 0)
            return; // 找到后停止搜索

        // 检查当前节点
        String nodeKey = node.getString("nodeKey");
        if (targetKey.equals(nodeKey)) {
            JSONArray assignees = node.getJSONArray("nodeAssigneeList");
            if (assignees != null) {
                result.addAll(assignees.toJavaList(NodeAssignee.class));
            }
            return;
        }

        // 递归查找子节点
        JSONObject childNode = node.getJSONObject("childNode");
        if (childNode != null) {
            findInNode(childNode, targetKey, result);
        }
    }

    private FlowCreator getFlowCreator() {
        return FlowCreator.of(SecurityFrameworkUtils.getLoginUserId().toString(), SecurityFrameworkUtils.getLoginUserNickname());
    }

    /**
     * 根据流程对象启动流程实例
     */
    // @PostMapping("{businessKey}")
    // public CommonResult<FlwInstance> start(@PathVariable Long businessKey,
    // @RequestBody FlwProcess flwProcess) {
    // FlwProcess process = flowLongEngine.processService()
    // .getProcessByKey(null, flwProcess.getProcessKey());
    // process.setModelContent(flwProcess.getModelContent());
    // return flowLongEngine.startProcessInstance(process, FlowCreator.of(SecurityFrameworkUtils.getLoginUserId().toString(), SecurityFrameworkUtils.getLoginUserNickname()), null, () ->
    // FlwInstance.of(String.valueOf(businessKey)))
    // .map(CommonResult::success)
    // .orElseGet(() ->
    // CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR, "启动流程失败,
    // 请稍后重试!"));
    // }
    public List<NodeModel> getUnsetAssigneeNodes(NodeModel rootNodeModel) {
        List<NodeModel> nodeModels = ModelHelper.getRootNodeAllChildNodes(rootNodeModel);
        //
        return nodeModels.stream().filter(
                        t -> ObjectUtils.isEmpty(t.getNodeAssigneeList()) && (NodeSetType.specifyMembers.eq(t.getSetType())
                                || NodeSetType.initiatorThemselves.eq(t.getSetType())
                                || NodeSetType.initiatorSelected.eq(t.getSetType())))
                .collect(Collectors.toList());
    }

    /**
     * 根据流程对象保存流程实例
     */
    @PostMapping("save/{businessKey}")
    public CommonResult<Boolean> save(@PathVariable Long businessKey, @RequestBody FlwProcess flwProcess) {
        Optional<List<FlwHisInstance>> optional = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        if (optional.isPresent() && optional.get()
                .stream()
                .anyMatch(e -> Arrays.asList(InstanceState.saveAsDraft)
                        .contains(InstanceState.get(e.getInstanceState())))) {
            optional.get().stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        result.set(flowLongEngine.runtimeService()
                                .updateInstanceModelById(instance.getId(),
                                        ModelHelper.buildProcessModel(flwProcess.getModelContent())));
                    });
        } else {
            FlwProcess process = flowLongEngine.processService()
                    .getProcessByKey(null, flwProcess.getProcessKey());
            process.setModelContent(flwProcess.getModelContent());
            flowLongEngine
                    .startProcessInstance(process, getFlowCreator(), null, true,
                            () -> FlwInstance.of(String.valueOf(businessKey)))
                    .ifPresent(e -> result.set(true));
        }

        return CommonResult.success(result.get());
    }

    @PostMapping("start/{businessKey}")
    public CommonResult<Boolean> start(@PathVariable Long businessKey, @RequestBody FlwProcessDTO flwProcess) {
        List<NodeModel> list = getUnsetAssigneeNodes(
                ModelHelper.buildProcessModel(flwProcess.getModelContent()).getNodeConfig());

        if (list.size() > 0) {
            String name = list.stream()
                    .map(NodeModel::getNodeName)
                    .collect(Collectors.joining("、"));
            return CommonResult.error(500, "请设置" + name + "处理人员节点");
        }

        Optional<List<FlwHisInstance>> optional = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        if (optional.isPresent() && optional.get()
                .stream()
                .anyMatch(e -> Arrays.asList(InstanceState.saveAsDraft)
                        .contains(InstanceState.get(e.getInstanceState())))) {
            optional.get().stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.runtimeService()
                                .updateInstanceModelById(instance.getId(),
                                        ModelHelper.buildProcessModel(flwProcess.getModelContent()));
                        // Optional<List<FlwHisTask>> hisTaskList = flowLongEngine.queryService()
                        // .getHisTasksByInstanceId(instance.getId());
                        //// 如果不存在历史流程,则说明还未启动, 只需要正常执行流程就好
                        // if (hisTaskList.isPresent() && hisTaskList.get().size() == 0) {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .filter(ObjectUtils::isNotEmpty)
                                .ifPresent(e -> {
                                    e.stream().findFirst()
                                            .ifPresent(task -> {
                                                flowLongEngine.executeTask(task.getId(), getFlowCreator(),
                                                        flwProcess.getVariable());
                                            });
                                });
                        // } else {
                        // // 如果存在历史流程, 则需要唤醒历史流程
                        // hisTaskList.ifPresent(e -> {
                        // e.forEach(task -> {
                        // if (task.getTaskState() == TaskState.revoke.getValue()) {
                        // flowLongEngine.taskService()
                        // .resume(task.getId(), getFlowCreator());
                        // }
                        // });
                        // });
                        // }
                        result.set(true);
                    });
        } else {
            FlwProcess process = flowLongEngine.processService()
                    .getProcessByKey(null, flwProcess.getProcessKey());
            process.setModelContent(flwProcess.getModelContent());
            flowLongEngine
                    .startProcessInstance(process, getFlowCreator(), flwProcess.getVariable(), false,
                            () -> FlwInstance.of(String.valueOf(businessKey)))
                    .ifPresent(e -> result.set(true));
        }

        return CommonResult.success(result.get());
    }

    private List<NodeModel> getAllParentNodeModels(NodeModel nodeModel) {
        List<NodeModel> nodeModels = new ArrayList<>();
        NodeModel parentNodeModel = nodeModel.getParentNode();
        if (null != parentNodeModel) {
            nodeModels.add(parentNodeModel);
            if (TaskType.major.eq(parentNodeModel.getType())) {
                return nodeModels;
            }
            // 继续往上递归
            List<NodeModel> pnmList = getAllParentNodeModels(parentNodeModel);
            if (!pnmList.isEmpty()) {
                nodeModels.addAll(pnmList);
            }
        }
        return nodeModels;
    }

    public List<FlwTask> getPreviousApprovalAndMajorNodes(NodeModel nodeModel) {
        List<FlwTask> list = new ArrayList<>();
        if (nodeModel == null) {
            return list;
        }
        // 获取所有父节点
        List<NodeModel> parentNodes = getAllParentNodeModels(nodeModel);

        // 遍历父节点，只保留审批节点和发起节点
        for (NodeModel parentNode : parentNodes) {
            Integer type = parentNode.getType();
            if (TaskType.approval.eq(type)) {
                FlwTask flwTask = new FlwTask();
                flwTask.setTaskKey(parentNode.getNodeKey());
                flwTask.setTaskName(parentNode.getNodeName());
                list.add(flwTask);
            }
        }

        return list;
    }

    /**
     * 根据instanceId获取可回退节点列表
     */
    @GetMapping("/getBackList/{instanceId}")
    public CommonResult<List<FlwTask>> getBackList(@PathVariable Long instanceId) {

        List<FlwTask> list = new ArrayList<>();
        Optional<List<FlwTask>> optional = flowLongEngine.queryService()
                .getActiveTasksByInstanceId(instanceId)
                .filter(ObjectUtils::isNotEmpty);

        optional.ifPresent(e -> {
            String taskKey = e.get(0).getTaskKey();
            FlwExtInstance extInstance = flowLongEngine.queryService()
                    .getExtInstance(instanceId);
            NodeModel model = ModelHelper.buildProcessModel(extInstance.getModelContent()).getNode(taskKey);
            list.addAll(getPreviousApprovalAndMajorNodes(model));
        });

        return CommonResult.success(list);

        // return optional.map(e -> CommonResult.success(e.stream()
        // .filter(task -> TaskType.approval.eq(task.getTaskType())
        // && TaskState.complete.eq(task.getTaskState())
        // &&
        // !optionalFlwTasks.get().stream().map(FlwTask::getTaskKey).collect(Collectors.toList()).contains(task.getTaskKey()))
        // .sorted(Comparator.comparing(FlwHisTask::getId))
        // .collect(Collectors.toList())))
        // .orElseGet(() -> CommonResult.success(Arrays.asList()));
    }

    /**
     * 根据subProcessId获取子流程实例ID
     */
    @GetMapping("/getSubInstanceId/{subProcessId}")
    public CommonResult<Long> getSubInstanceId(@PathVariable Long subProcessId, String businessKey) {
        List<FlwHisInstance> list = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                .eq(FlwHisInstance::getProcessId, subProcessId)
                .list();
        if (ObjectUtils.isEmpty(list)) {
            return CommonResult.success(null);
        }

        List<FlwHisInstance> parentList = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                .eq(FlwHisInstance::getBusinessKey, businessKey)
                .in(FlwHisInstance::getId,
                        list.stream().map(FlwHisInstance::getParentInstanceId).collect(Collectors.toList()))
                .list();

        return CommonResult.success(list.stream()
                .filter(e -> parentList.stream().map(FlwHisInstance::getId).collect(Collectors.toList())
                        .contains(e.getParentInstanceId()))
                .findFirst()
                .orElse(new FlwHisInstance())
                .getId());
    }

    /**
     * 根据businessKey获取流程状态
     */
    @GetMapping("/getInstanceInfo/{businessKey}")
    public CommonResult<InstanceInfoVO> getInstanceInfo(@PathVariable Long businessKey) {
        List<FlwHisInstance> list = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey))
                .orElseGet(() -> Arrays.asList(flowLongEngine.queryService().getHistInstance(businessKey)));
        return CommonResult.success(list.stream()
                .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                .map(e -> new InstanceInfoVO()
                        .setInstanceId(e.getId())
                        .setTaskState(e.getInstanceState())
                        .setCurrentNodeKey(e.getCurrentNodeKey()))
                .findFirst()
                .orElse(new InstanceInfoVO().setTaskState(InstanceState.active.getValue())));
    }

    /**
     * 根据businessKey获取流程实例模型
     */
    @GetMapping("/{businessKey}")
    public CommonResult<FlwExtInstance> getInstanceModel(@PathVariable Long businessKey) {
        List<FlwHisInstance> list = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey))
                .orElseGet(() -> Arrays.asList(flowLongEngine.queryService().getHistInstance(businessKey)));
        AtomicReference<FlwExtInstance> processModel = new AtomicReference<>();

        if (list.size() > 0) {
            list.stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        processModel.set(flowLongEngine.queryService()
                                .getExtInstance(instance.getId()));
                    });
        }

        return CommonResult.success(processModel.get());
    }

    /**
     * 根据businessKey获取流程任务列表
     */
    @GetMapping("/getTaskList/{businessKey}")
    public CommonResult<List<FlwHisTask>> getTaskList(@PathVariable Long businessKey) {
        List<FlwHisInstance> list = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey))
                .orElseGet(() -> Arrays.asList(flowLongEngine.queryService().getHistInstance(businessKey)));

        List<FlwHisTask> collect = new ArrayList<>();
        list.stream()
                .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                .findFirst()
                .ifPresent(instance -> {
                    flowLongEngine.queryService()
                            .getHisTasksByInstanceId(instance.getId())
                            .map(taskList -> taskList.stream()
                                    .filter(task -> TaskType.cc.ne(task.getTaskType()))
                                    .map(task -> {
                                        flowLongEngine.queryService()
                                                .getHisTaskActorsByTaskId(task.getId())
                                                .stream()
                                                .findFirst()
                                                .ifPresent(actor -> {
                                                    task.setAssignorId(actor.getActorId());
                                                    task.setAssignor(actor.getActorName());
                                                });
                                        return task;
                                    })
                                    .collect(Collectors.toList()))
                            .ifPresent(collect::addAll);
                    flowLongEngine.queryService()
                            .getActiveTaskActorsByInstanceId(instance.getId())
                            .filter(ObjectUtils::isNotEmpty)
                            .ifPresent(actors -> {
                                FlwTask task = flowLongEngine.queryService()
                                        .getTask(actors.get(0).getTaskId());
                                collect.addAll(actors.stream()
                                        .map(actor -> {
                                            task.setAssignorId(actor.getActorId());
                                            task.setAssignor(actor.getActorName());
                                            return FlwHisTask.of(task, TaskState.active);
                                        }).collect(Collectors.toList()));
                            });
                });
        return CommonResult.success(collect);
    }

    /**
     * 根据businessKey撤销流程实例
     */
    @PutMapping("/revoke/{businessKey}")
    public CommonResult<Boolean> revoke(@PathVariable Long businessKey) {
        // TODO:流程审批中的人才可以撤销
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    FlwTask flwTask = tasks.stream().findFirst().get();
                                    result.set(flowLongEngine.runtimeService()
                                            .revoke(instance.getId(), flwTask, getFlowCreator()));
                                });
                    });
        });

        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey同意流程
     */
    @PutMapping("/approve/{businessKey}")
    public CommonResult<Boolean> approve(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey))
                .ifPresent(e -> {
                    e.stream().findFirst()
                            .ifPresent(instance -> {
                                Optional<FlwInstance> childInstance = ChainWrappers.lambdaQueryChain(flwInstanceMapper)
                                        .eq(FlwInstance::getParentInstanceId, instance.getId())
                                        .last("limit 1")
                                        .oneOpt()
                                        .filter(ObjectUtils::isNotEmpty);
                                flowLongEngine.queryService().getActiveTasksByInstanceId(
                                                childInstance.isPresent() ? childInstance.get().getId() : instance.getId())
                                        .filter(ObjectUtils::isNotEmpty)
                                        .ifPresent(task -> {
                                            FlwTask flwTask = task.get(0);
                                            flowLongEngine.createCcTask(flwTask, data.getCcUsers(), getFlowCreator());
                                            result.set(flowLongEngine.executeTask(flwTask.getId(), getFlowCreator(),
                                                    data.getVariable()));
                                        });
                            });
                });
        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey驳回至上一步处理人
     */
    @PutMapping("/reject/{businessKey}")
    public CommonResult<Boolean> reject(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    tasks.stream()
                                            .findFirst()
                                            .ifPresent(task -> {
                                                // 如果上一个节点是发起人,那么直接执行撤销操作
                                                ProcessModel processModel = flowLongEngine.queryService()
                                                        .getExtInstance(instance.getId()).model();
                                                NodeModel parentNode = processModel.getNode(task.getTaskKey()).getParentNode();
                                                if (parentNode.conditionNode()) {
                                                    parentNode = parentNode.getParentNode();
                                                }
                                                if (ObjectUtils.isNotEmpty(parentNode.getTermAuto()) && parentNode.getTermAuto()) {
                                                    task.setExpireTime(DateUtils.addHours(new Date(), parentNode.getTerm()));
                                                }
                                                flowLongEngine.executeRejectTask(
                                                        task,
                                                        null,
                                                        getFlowCreator(),
                                                        data.getVariable(),
                                                        TaskType.major.eq(parentNode.getType())).ifPresent(e1 -> {
                                                    flowLongEngine.createCcTask(task, data.getCcUsers(),
                                                            getFlowCreator());
                                                    result.set(true);
                                                });
                                                // if(TaskType.major.eq(parentNode.getType())){
                                                // flowLongEngine.executeJumpTask(task.getParentTaskId(),
                                                // parentNode.getNodeKey(), getFlowCreator(), null, TaskType.reApproveJump)
                                                // .ifPresent(e1 -> {
                                                // // 需要改变一下流程实例的状态为reject
                                                // result.set(true);
                                                // });
                                                // }else {
                                                // flowLongEngine.taskService()
                                                // .rejectTask(task, getFlowCreator());
                                                // }
                                            });
                                });
                    });
        });

        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey终止流程
     */
    @PutMapping("/terminate/{businessKey}")
    public CommonResult<Boolean> terminate(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    FlwTask flwTask = tasks.stream().findFirst().get();
                                    result.set(flowLongEngine.runtimeService()
                                            .terminate(instance.getId(), flwTask, getFlowCreator()));
                                    flowLongEngine.createCcTask(flwTask, data.getCcUsers(),
                                            getFlowCreator());
                                });
                    });
        });

        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey和taskKey回退流程
     */
    @PutMapping("/reclaim/{businessKey}")
    public CommonResult<Boolean> reclaim(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    tasks.stream()
                                            .findFirst()
                                            .ifPresent(task -> {
                                                flowLongEngine.executeRejectTask(
                                                        task,
                                                        data.getReclaimNodeKey(),
                                                        getFlowCreator(),
                                                        data.getVariable()).ifPresent(e1 -> {
                                                    ChainWrappers.lambdaUpdateChain(flwHisTaskMapper)
                                                            .set(FlwHisTask::getTaskState,
                                                                    TaskState.jump.getValue())
                                                            .eq(FlwHisTask::getId, task.getId())
                                                            .update(new FlwHisTask());
                                                    flowLongEngine.createCcTask(task, data.getCcUsers(),
                                                            getFlowCreator());
                                                    result.set(true);
                                                });
                                            });
                                });
                    });
        });
        // flowLongEngine.executeJumpTask(taskId, flwTask.getTaskKey(), getFlowCreator(),
        // null, TaskType.jump)
        // .ifPresent(e -> {
        // result.set(true);
        // });

        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey和转交人转交任务
     */
    @PutMapping("/transfer/{businessKey}")
    public CommonResult<Boolean> transfer(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    tasks.stream()
                                            .findFirst()
                                            .ifPresent(task -> {
                                                result.set(flowLongEngine.taskService()
                                                        .transferTask(task.getId(), getFlowCreator(),
                                                                data.getTransferUsers(), data.getVariable()));
                                                flowLongEngine.createCcTask(task, data.getCcUsers(), getFlowCreator());
                                            });
                                });
                    });
        });
        // flowLongEngine.executeJumpTask(taskId, flwTask.getTaskKey(), getFlowCreator(),
        // null, TaskType.jump)
        // .ifPresent(e -> {
        // result.set(true);
        // });

        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey加签任务
     */
    @PutMapping("/countersign/{businessKey}")
    public CommonResult<Boolean> countersign(@PathVariable Long businessKey, @RequestBody ActionDTO data) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .ifPresent(tasks -> {
                                    tasks.stream()
                                            .findFirst()
                                            .ifPresent(task -> {
                                                NodeModel nodeModel = new NodeModel();
                                                nodeModel.setNodeName(data.getNodeName());
                                                nodeModel.setNodeKey("flk" + new Date().getTime());
                                                nodeModel.setType(1);
                                                nodeModel.setSetType(1);
                                                nodeModel.setExamineMode(1);
                                                nodeModel.setRemind(true);
                                                nodeModel.setApproveSelf(0);
                                                nodeModel.setNodeAssigneeList(data.getCounterSignUsers());
                                                boolean addResult = flowLongEngine.executeAppendNodeModel(
                                                        task.getId(),
                                                        nodeModel,
                                                        // FlowCreator.of(task.getCreateId(), task.getCreateBy()),
                                                        getFlowCreator(),
                                                        data.getVariable(),
                                                        data.getSignType());
                                                if (addResult) {
                                                    result.set(data.getSignType() ? true
                                                            : flowLongEngine.executeTask(task.getId(), getFlowCreator(),
                                                            data.getVariable()));
                                                }
                                                flowLongEngine.createCcTask(task, data.getCcUsers(), getFlowCreator());
                                            });
                                });
                    });
        });
        return CommonResult.success(result.get());
    }

    /**
     * 待我处理任务数量
     */
    @GetMapping("/todoCount")
    public CommonResult<Long> todoCount() {
        return CommonResult.success(taskService.todoCount());
    }

    /**
     * 已处理任务数量
     */
    @GetMapping("/doneCount")
    public CommonResult<Long> doneCount() {
        return CommonResult.success(taskService.doneCount());
    }

    /**
     * 我发起的数量
     */
    @GetMapping("/submitCount")
    public CommonResult<Long> submitCount() {
        return CommonResult.success(taskService.submitCount());
    }

    /**
     * 抄送我的数量
     */
    @GetMapping("/aboutCount")
    public CommonResult<Long> aboutCount() {
        return CommonResult.success(taskService.aboutCount());
    }

    /**
     * 待我处理
     */
    @GetMapping("/todoList")
    public CommonResult<IPage<TodoListVO>> todoList(Page page) {
        return CommonResult.success(taskService.todoList(page));
    }

    /**
     * 已处理的
     */
    @GetMapping("/doneList")
    public CommonResult<IPage<DoneListVO>> doneList(Page page) {
        return CommonResult.success(taskService.doneList(page));
    }

    /**
     * 我发起的
     */
    @GetMapping("/submitList/{isAll}")
    public CommonResult<IPage<SubmitListVO>> submitList(@PathVariable boolean isAll, Page page) {
        return CommonResult.success(taskService.submitList(isAll, page));
    }

    /**
     * 抄送我的
     */
    @GetMapping("/aboutList")
    public CommonResult<IPage<AboutListVO>> aboutList(Page page) {
        return CommonResult.success(taskService.aboutList(page));
    }

    @Override
    public List<FlwTaskActor> getTaskActors(NodeModel nodeModel, Execution execution) {
        List<FlwTaskActor> flwTaskActors = new ArrayList<>();
        final Integer actorType = this.getActorType(nodeModel);
        List<NodeAssignee> nodeAssigneeList = nodeModel.getNodeAssigneeList();
        FlwInstance instance = execution.getFlwInstance();
        if (ObjectUtils.isEmpty(instance.getBusinessKey())
                && ObjectUtils.isNotEmpty(instance.getParentInstanceId())) {
            String modelContent = ChainWrappers.lambdaQueryChain(flwExtInstanceMapper)
                    .select(FlwExtInstance::getModelContent)
                    .eq(FlwExtInstance::getId, instance.getParentInstanceId())
                    .last("limit 1")
                    .one().getModelContent();
            JSONObject root = JSON.parseObject(modelContent);
            JSONObject nodeConfig = findNodeConfig(root.getJSONObject("nodeConfig"),
                    instance.getProcessId().toString());
            nodeAssigneeList.addAll(findAssigneesByNodeKey(nodeConfig, nodeModel.getNodeKey()));
        }
        if (ActorType.user.eq(actorType)) {
            flwTaskActors.addAll(nodeAssigneeList.stream()
                    .map(e -> FlwTaskActor.ofNodeAssignee(e))
                    .collect(Collectors.toList()));
        } else if (ActorType.role.eq(actorType)) {
            // 获取所有的角色ID
            List<String> roleIds = nodeAssigneeList.stream()
                    .map(NodeAssignee::getId)
                    .collect(Collectors.toList());
            flwTaskActors.addAll(adminUserApi.getUserListByRoleIds(roleIds)
                    .stream()
                    .map(e -> FlwTaskActor.ofFlowCreator(FlowCreator.of(e.getId().toString(), e.getNickname())))
                    .collect(Collectors.toList()));
        } else if (ActorType.department.eq(actorType)) {
            // 获取所有的部门ID
            List<Long> deptIds = nodeAssigneeList.stream()
                    .map(NodeAssignee::getId)
                    .map(Long::valueOf)
                    .collect(Collectors.toList());
            flwTaskActors.addAll(adminUserApi.getUserListByDeptIds(deptIds)
                    .stream()
                    .map(e -> FlwTaskActor.ofFlowCreator(FlowCreator.of(e.getId().toString(), e.getNickname())))
                    .collect(Collectors.toList()));
        } else {
            // 主管需要获取发起人
            FlowCreator flowCreator = execution.getFlowCreator();
            Long userId = Long.valueOf(flowCreator.getCreateId());
            if (NodeSetType.supervisor.eq(nodeModel.getSetType())) {
                Integer examineLevel = nodeModel.getExamineLevel();
                AdminUserRespDTO userInfo = adminUserApi.getNthLevelLeader(userId, examineLevel);
                flwTaskActors.add(FlwTaskActor.ofFlowCreator(FlowCreator.of(userInfo.getId().toString(), userInfo.getNickname())));
            } else {
                if (nodeModel.getDirectorMode() == 0) {
                    flwTaskActors.addAll(adminUserApi.getAllLeaderChain(userId)
                            .stream()
                            .map(e -> FlwTaskActor.ofFlowCreator(FlowCreator.of(e.getId().toString(), e.getNickname())))
                            .collect(Collectors.toList()));
                } else {
                    Integer directorLevel = nodeModel.getDirectorLevel();
                    flwTaskActors.addAll(adminUserApi.getNthLevelLeaderList(userId, directorLevel)
                            .stream()
                            .map(e -> FlwTaskActor.ofFlowCreator(FlowCreator.of(e.getId().toString(), e.getNickname())))
                            .collect(Collectors.toList()));
                }
            }
        }
        return ObjectUtils.isEmpty(flwTaskActors) ? null : flwTaskActors;
    }

    @Override
    public Integer getActorType(NodeModel nodeModel) {
        // 0，用户
        if (NodeSetType.specifyMembers.eq(nodeModel.getSetType())
                || NodeSetType.initiatorThemselves.eq(nodeModel.getSetType())
                || NodeSetType.initiatorSelected.eq(nodeModel.getSetType())) {
            return 0;
        }

        // 1，角色
        if (NodeSetType.role.eq(nodeModel.getSetType())) {
            return 1;
        }

        // 2，部门
        if (NodeSetType.department.eq(nodeModel.getSetType())) {
            return 2;
        }

        // 3，主管 && 连续多级主管
        if (NodeSetType.supervisor.eq(nodeModel.getSetType())
                || NodeSetType.multiLevelSupervisors.eq(nodeModel.getSetType())) {
            return 3;
        }
        return 0;
    }
}
