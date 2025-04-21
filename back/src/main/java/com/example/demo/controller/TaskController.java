package com.example.demo.controller;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.InstanceState;
import com.aizuda.bpm.engine.core.enums.TaskState;
import com.aizuda.bpm.engine.core.enums.TaskType;
import com.aizuda.bpm.engine.entity.*;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.demo.common.pojo.CommonResult;
import com.example.demo.entity.*;
import com.example.demo.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import java.util.stream.Collectors;

@Slf4j
@RestController
@RequestMapping("/task")
@RequiredArgsConstructor
public class TaskController {
    private final static FlowCreator testCreator = FlowCreator.of("20240815", "田重辉");
    private final FlowLongEngine flowLongEngine;
    private final TaskService taskService;

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
    @PostMapping("start/{businessKey}")
    public CommonResult<Boolean> start(@PathVariable Long businessKey, @RequestBody FlwProcess flwProcess) {
        List<NodeModel> list = ModelHelper.getUnsetAssigneeNodes(ModelHelper.buildProcessModel(flwProcess.getModelContent()).getNodeConfig());

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

    /**
     * 根据instanceId获取可回退节点列表
     */
    @GetMapping("/getBackList/{instanceId}")
    public CommonResult<List<FlwHisTask>> getBackList(@PathVariable Long instanceId) {
        Optional<List<FlwHisTask>> optional = flowLongEngine.queryService()
                .getHisTasksByInstanceId(instanceId);

        return optional.map(e -> CommonResult.success(e.stream()
                        .filter(task -> TaskType.approval.eq(task.getTaskType()))
                        .sorted(Comparator.comparing(FlwHisTask::getId))
                        .collect(Collectors.toList())))
                .orElseGet(() -> CommonResult.success(Arrays.asList()));
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
                                    //.filter(task -> task.getTaskState() != TaskState.revoke.getValue())
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
                    List<FlwHisTask> flwTaskList = flowLongEngine.queryService()
                            .getTasksByInstanceId(instance.getId())
                            .stream()
                            .map(task -> {
                                flowLongEngine.queryService()
                                        .getTaskActorsByTaskId(task.getId())
                                        .stream()
                                        .findFirst()
                                        .ifPresent(actor -> {
                                            task.setAssignorId(actor.getActorId());
                                            task.setAssignor(actor.getActorName());
                                        });
                                return FlwHisTask.of(task, TaskState.active);
                            })
                            .collect(Collectors.toList());
                    collect.addAll(flwTaskList);
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
    public CommonResult<Boolean> approve(@PathVariable Long businessKey) {
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey))
                .ifPresent(e -> {
                    e.stream().findFirst()
                            .ifPresent(instance -> {
                                flowLongEngine.queryService().getActiveTasksByInstanceId(instance.getId())
                                        .ifPresent(task -> {
                                            FlwTask flwTask = task.get(0);
                                            flowLongEngine.executeTask(flwTask.getId(), testCreator);
                                            ProcessModel processModel = flowLongEngine.queryService()
                                                    .getExtInstance(instance.getId()).model();
                                            List<NodeModel> nextChildNodes = ModelHelper.getNextChildNodes(flowLongEngine.getContext(), new Execution(testCreator, null),
                                                    processModel.getNodeConfig(), flwTask.getTaskKey());
                                            if (nextChildNodes.isEmpty()) {
                                                result.set(true);
                                            }
                                            nextChildNodes.forEach(child -> {
                                                result.set(!ModelHelper.checkExistApprovalNode(child));
                                            });
                                        });
                            });
                });
        return CommonResult.success(result.get());
    }

    /**
     * 根据businessKey驳回至上一步处理人
     */
    @PutMapping("/reject/{businessKey}")
    public CommonResult<Boolean> reject(@PathVariable Long businessKey) {
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
                                                flowLongEngine.executeRejectTask(
                                                        task,
                                                        parentNode.getNodeKey(),
                                                        testCreator,
                                                        null,
                                                        TaskType.major.eq(parentNode.getType())
                                                ).ifPresent(e1 -> {
                                                    result.set(TaskType.major.eq(parentNode.getType()));
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
    public CommonResult<Boolean> terminate(@PathVariable Long businessKey) {
        Optional<List<FlwInstance>> optional = flowLongEngine.queryService()
                .getInstancesByBusinessKey(String.valueOf(businessKey));
        AtomicReference<Boolean> result = new AtomicReference<>(false);
        optional.ifPresent(e -> {
            e.stream().findFirst()
                    .ifPresent(instance -> {
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
    public CommonResult<Boolean> reclaim(@PathVariable Long businessKey, @RequestBody FlwTask flwTask) {
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
                                                        flwTask.getTaskKey(),
                                                        testCreator,
                                                        null
                                                ).ifPresent(e1 -> {
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
     * 根据businessKey转交任务
     */
    @PutMapping("/transfer/{taskId}")
    public CommonResult<Boolean> transfer(@PathVariable Long taskId) {
        return CommonResult.success(flowLongEngine.taskService()
                .transferTask(taskId, testCreator, testCreator));
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

}
