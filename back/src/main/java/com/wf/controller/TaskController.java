package com.wf.controller;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.FlowLongIdGenerator;
import com.aizuda.bpm.engine.TaskActorProvider;
import com.aizuda.bpm.engine.assist.DateUtils;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.*;
import com.aizuda.bpm.engine.entity.*;
import com.aizuda.bpm.engine.impl.GeneralTaskActorProvider;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeAssignee;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.aizuda.bpm.mybatisplus.mapper.FlwExtInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisInstanceMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwInstanceMapper;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONArray;
import com.alibaba.fastjson2.JSONObject;
import com.alibaba.fastjson2.util.UUIDUtils;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.wf.common.pojo.CommonResult;
import com.wf.entity.*;
import com.wf.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/task")
@RequiredArgsConstructor
public class TaskController implements TaskActorProvider {
    private final static FlowCreator testCreator = FlowCreator.of("20240815", "田重辉");
    private final static FlowCreator testCreator2 = FlowCreator.of("20240815", "田重辉2");
    private final static FlowCreator testCreator3 = FlowCreator.of("20240815", "田重辉3");
    private final static FlowCreator testCreator4 = FlowCreator.of("20240815", "田重辉4");
    private final FlowLongEngine flowLongEngine;
    private final TaskService taskService;
    private final FlwInstanceMapper flwInstanceMapper;
    private final FlwHisInstanceMapper flwHisInstanceMapper;
    private final FlwExtInstanceMapper flwExtInstanceMapper;


    /**
     * 根据流程对象启动流程实例
     */
    //@PostMapping("{businessKey}")
    //public CommonResult<FlwInstance> start(@PathVariable Long businessKey, @RequestBody FlwProcess flwProcess) {
    //    FlwProcess process = flowLongEngine.processService()
    //            .getProcessByKey(null, flwProcess.getProcessKey());
    //    process.setModelContent(flwProcess.getModelContent());
    //    return flowLongEngine.startProcessInstance(process, testCreator, null, () -> FlwInstance.of(String.valueOf(businessKey)))
    //            .map(CommonResult::success)
    //            .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR, "启动流程失败, 请稍后重试!"));
    //}
    public List<NodeModel> getUnsetAssigneeNodes(NodeModel rootNodeModel) {
        List<NodeModel> nodeModels = ModelHelper.getRootNodeAllChildNodes(rootNodeModel);
        //
        return nodeModels.stream().filter(t -> ObjectUtils.isEmpty(t.getNodeAssigneeList()) && (NodeSetType.specifyMembers.eq(t.getSetType())
                || NodeSetType.initiatorThemselves.eq(t.getSetType())
                || NodeSetType.initiatorSelected.eq(t.getSetType()))).collect(Collectors.toList());
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
                .anyMatch(e ->
                        Arrays.asList(InstanceState.saveAsDraft)
                                .contains(InstanceState.get(e.getInstanceState())))) {
            optional.get().stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        result.set(flowLongEngine.runtimeService()
                                .updateInstanceModelById(instance.getId(), ModelHelper.buildProcessModel(flwProcess.getModelContent())));
                    });
        } else {
            FlwProcess process = flowLongEngine.processService()
                    .getProcessByKey(null, flwProcess.getProcessKey());
            process.setModelContent(flwProcess.getModelContent());
            flowLongEngine.startProcessInstance(process, testCreator, null, true, () -> FlwInstance.of(String.valueOf(businessKey)))
                    .ifPresent(e -> result.set(true));
        }

        return CommonResult.success(result.get());
    }

    @PostMapping("start/{businessKey}")
    public CommonResult<Boolean> start(@PathVariable Long businessKey, @RequestBody FlwProcess flwProcess) {
        List<NodeModel> list = getUnsetAssigneeNodes(ModelHelper.buildProcessModel(flwProcess.getModelContent()).getNodeConfig());

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
                .anyMatch(e ->
                        Arrays.asList(InstanceState.saveAsDraft)
                                .contains(InstanceState.get(e.getInstanceState())))) {
            optional.get().stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        flowLongEngine.runtimeService()
                                .updateInstanceModelById(instance.getId(), ModelHelper.buildProcessModel(flwProcess.getModelContent()));
                        //Optional<List<FlwHisTask>> hisTaskList = flowLongEngine.queryService()
                        //        .getHisTasksByInstanceId(instance.getId());
                        //// 如果不存在历史流程,则说明还未启动, 只需要正常执行流程就好
                        //if (hisTaskList.isPresent() && hisTaskList.get().size() == 0) {
                        flowLongEngine.queryService()
                                .getActiveTasksByInstanceId(instance.getId())
                                .filter(ObjectUtils::isNotEmpty)
                                .ifPresent(e -> {
                                    e.stream().findFirst()
                                            .ifPresent(task -> {
                                                flowLongEngine.executeTask(task.getId(), testCreator);
                                            });
                                });
                        //} else {
                        //    // 如果存在历史流程, 则需要唤醒历史流程
                        //    hisTaskList.ifPresent(e -> {
                        //        e.forEach(task -> {
                        //            if (task.getTaskState() == TaskState.revoke.getValue()) {
                        //                flowLongEngine.taskService()
                        //                        .resume(task.getId(), testCreator);
                        //            }
                        //        });
                        //    });
                        //}
                        result.set(true);
                    });
        } else {
            FlwProcess process = flowLongEngine.processService()
                    .getProcessByKey(null, flwProcess.getProcessKey());
            process.setModelContent(flwProcess.getModelContent());
            flowLongEngine.startProcessInstance(process, testCreator, null, false, () -> FlwInstance.of(String.valueOf(businessKey)))
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

        //return optional.map(e -> CommonResult.success(e.stream()
        //                .filter(task -> TaskType.approval.eq(task.getTaskType())
        //                        && TaskState.complete.eq(task.getTaskState())
        //                        && !optionalFlwTasks.get().stream().map(FlwTask::getTaskKey).collect(Collectors.toList()).contains(task.getTaskKey()))
        //                .sorted(Comparator.comparing(FlwHisTask::getId))
        //                .collect(Collectors.toList())))
        //        .orElseGet(() -> CommonResult.success(Arrays.asList()));
    }


    /**
     * 根据subProcessId获取子流程实例ID
     */
    @GetMapping("/getSubInstanceId/{subProcessId}")
    public CommonResult<Long> getSubInstanceId(@PathVariable Long subProcessId, String businessKey) {
        List<FlwHisInstance> list = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                .eq(FlwHisInstance::getProcessId, subProcessId)
                .list();
        if(ObjectUtils.isEmpty(list)){
            return CommonResult.success(null);
        }

        List<FlwHisInstance> parentList = ChainWrappers.lambdaQueryChain(flwHisInstanceMapper)
                .eq(FlwHisInstance::getBusinessKey, businessKey)
                .in(FlwHisInstance::getId, list.stream().map(FlwHisInstance::getParentInstanceId).collect(Collectors.toList()))
                .list();

        return CommonResult.success(list.stream()
                .filter(e -> parentList.stream().map(FlwHisInstance::getId).collect(Collectors.toList()).contains(e.getParentInstanceId()))
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
                        .setTaskState(e.getInstanceState()))
                .findFirst()
                .orElse(new InstanceInfoVO().setTaskState(InstanceState.active.getValue())));
    }

    /**
     * 根据businessKey获取流程实例模型
     */
    @GetMapping("/{businessKey}")
    public CommonResult<String> getInstanceModel(@PathVariable Long businessKey) {
        List<FlwHisInstance> list = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey))
                .orElseGet(() -> Arrays.asList(flowLongEngine.queryService().getHistInstance(businessKey)));
        AtomicReference<String> processModel = new AtomicReference<>();

        if (list.size() > 0) {
            list.stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        processModel.set(flowLongEngine.queryService()
                                .getExtInstance(instance.getId()).getModelContent());
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
        //TODO:流程审批中的人才可以撤销
        Optional<List<FlwHisInstance>> optional = flowLongEngine.queryService()
                .getHisInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream()
                    .sorted(Comparator.comparing(FlwHisInstance::getId).reversed())
                    .findFirst()
                    .ifPresent(instance -> {
                        result.set(flowLongEngine.runtimeService()
                                .revoke(instance.getId(), testCreator));
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
                                flowLongEngine.queryService().getActiveTasksByInstanceId(childInstance.isPresent() ? childInstance.get().getId() : instance.getId())
                                        .filter(ObjectUtils::isNotEmpty)
                                        .ifPresent(task -> {
                                            FlwTask flwTask = task.get(0);
                                            flowLongEngine.createCcTask(flwTask, data.getCcUsers(), testCreator);
                                            result.set(flowLongEngine.executeTask(flwTask.getId(), testCreator, data.getVariable()));
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
                                                NodeModel parentNode = processModel.getNode(task.getTaskKey())
                                                        .getParentNode();
                                                HashMap<String, Object> variable = data.getVariable();
                                                variable.putIfAbsent("rejectNodeName", parentNode.getNodeName());
                                                flowLongEngine.executeRejectTask(
                                                        task,
                                                        parentNode.getNodeKey(),
                                                        testCreator,
                                                        variable,
                                                        TaskType.major.eq(parentNode.getType())
                                                ).ifPresent(e1 -> {
                                                    flowLongEngine.createCcTask(task, data.getCcUsers(), testCreator);
                                                    result.set(true);
                                                });
                                                //if(TaskType.major.eq(parentNode.getType())){
                                                //    flowLongEngine.executeJumpTask(task.getParentTaskId(), parentNode.getNodeKey(), testCreator, null, TaskType.reApproveJump)
                                                //                    .ifPresent(e1 -> {
                                                //                        // 需要改变一下流程实例的状态为reject
                                                //                        result.set(true);
                                                //                    });
                                                //}else {
                                                //    flowLongEngine.taskService()
                                                //            .rejectTask(task, testCreator);
                                                //}
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
                                    flowLongEngine.createCcTask(tasks.stream().findFirst().get(), data.getCcUsers(), testCreator);
                                });
                        result.set(flowLongEngine.runtimeService()
                                .terminate(instance.getId(), testCreator));
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
                                                        testCreator,
                                                        data.getVariable()
                                                ).ifPresent(e1 -> {
                                                    flowLongEngine.createCcTask(task, data.getCcUsers(), testCreator);
                                                    result.set(true);
                                                });
                                            });
                                });
                    });
        });
        //flowLongEngine.executeJumpTask(taskId, flwTask.getTaskKey(), testCreator, null, TaskType.jump)
        //        .ifPresent(e -> {
        //            result.set(true);
        //        });

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
                                                        .transferTask(task.getId(), testCreator, data.getTransferUsers()));
                                                flowLongEngine.createCcTask(task, data.getCcUsers(), testCreator);
                                            });
                                });
                    });
        });
        //flowLongEngine.executeJumpTask(taskId, flwTask.getTaskKey(), testCreator, null, TaskType.jump)
        //        .ifPresent(e -> {
        //            result.set(true);
        //        });

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
                                                nodeModel.setNodeKey("flk" + DateUtils.getCurrentDate().getTime());
                                                nodeModel.setType(1);
                                                nodeModel.setSetType(1);
                                                nodeModel.setExamineMode(1);
                                                nodeModel.setNodeAssigneeList(data.getCounterSignUsers());
                                                boolean addResult = flowLongEngine.executeAppendNodeModel(
                                                        task.getId(),
                                                        nodeModel,
                                                        //FlowCreator.of(task.getCreateId(), task.getCreateBy()),
                                                        testCreator,
                                                        data.getVariable(),
                                                        data.getSignType()
                                                );
                                                if(addResult){
                                                    result.set(data.getSignType() ? true : flowLongEngine.executeTask(task.getId(), testCreator, data.getVariable()));
                                                }
                                                flowLongEngine.createCcTask(task, data.getCcUsers(), testCreator);
                                            });
                                });
                    });
        });
        return CommonResult.success(result.get());
    }

    /**
     * 任务统计
     */
    @GetMapping("/count")
    public CommonResult<JSONObject> taskCount() {
        return CommonResult.success(taskService.taskCount());
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
        //if(ObjectUtils.isEmpty(instance.getBusinessKey())
        //    && ObjectUtils.isNotEmpty(instance.getParentInstanceId())){
        //    String modelContent = ChainWrappers.lambdaQueryChain(flwExtInstanceMapper)
        //            .select(FlwExtInstance::getModelContent)
        //            .eq(FlwExtInstance::getId, instance.getParentInstanceId())
        //            .last("limit 1")
        //            .one().getModelContent();
        //    JSONObject root = JSON.parseObject(modelContent);
        //    JSONObject nodeConfig = findNodeConfig(root.getJSONObject("nodeConfig"), instance.getProcessId().toString());
        //    nodeAssigneeList.addAll(findAssigneesByNodeKey(nodeConfig, nodeModel.getNodeKey()));
        //}
        if (ActorType.user.eq(actorType)) {
            flwTaskActors.addAll(nodeAssigneeList.stream()
                    .map(e -> FlwTaskActor.ofNodeAssignee(e))
                    .collect(Collectors.toList()));
        } else if (ActorType.role.eq(actorType)) {
            // 获取所有的角色ID
            List<String> roleIds = nodeAssigneeList.stream()
                    .map(NodeAssignee::getId)
                    .collect(Collectors.toList());
            // TODO: 根据角色ID获取所有的用户信息
            flwTaskActors.addAll(nodeModel.getNodeAssigneeList().stream()
                    .map(e -> FlwTaskActor.ofFlowCreator(testCreator))
                    .collect(Collectors.toList()));
        } else if (ActorType.department.eq(actorType)) {
            // 获取所有的部门ID
            List<String> roleIds = nodeAssigneeList.stream()
                    .map(NodeAssignee::getId)
                    .collect(Collectors.toList());
            // TODO: 根据部门ID获取所有的用户信息
            flwTaskActors.addAll(nodeModel.getNodeAssigneeList().stream()
                    .map(e -> FlwTaskActor.ofFlowCreator(testCreator))
                    .collect(Collectors.toList()));
        } else {
            // 主管需要获取发起人
            FlowCreator flowCreator = execution.getFlowCreator();
            String createId = flowCreator.getCreateId();
            if (NodeSetType.supervisor.eq(nodeModel.getSetType())) {
                Integer examineLevel = nodeModel.getExamineLevel();
                // TODO: 获取指定层级主管, 单人
                flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator));
            } else {
                if (nodeModel.getDirectorMode() == 0) {
                    // TODO: 获取直到最上级主管
                    flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator2));
                    flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator3));
                    flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator4));
                } else {
                    // TODO: 获取指定层级主管, 多人
                    Integer directorLevel = nodeModel.getDirectorLevel();
                    flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator2));
                    flwTaskActors.add(FlwTaskActor.ofFlowCreator(testCreator3));
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
        if (NodeSetType.supervisor.eq(nodeModel.getSetType()) || NodeSetType.multiLevelSupervisors.eq(nodeModel.getSetType())) {
            return 3;
        }
        return 0;
    }

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

    public static List<NodeAssignee> findAssigneesByNodeKey(JSONObject rootNode, String targetNodeKey) {
        List<NodeAssignee> result = new ArrayList<>();
        findInNode(rootNode, targetNodeKey, result);
        return result;
    }

    private static void findInNode(JSONObject node, String targetKey, List<NodeAssignee> result) {
        if (node == null || result.size() > 0) return; // 找到后停止搜索

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
}
