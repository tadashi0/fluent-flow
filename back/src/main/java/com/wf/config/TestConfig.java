package com.wf.config;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.FlowLongScheduler;
import com.aizuda.bpm.engine.TaskReminder;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.enums.TaskEventType;
import com.aizuda.bpm.engine.entity.FlwInstance;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.engine.entity.FlwTaskActor;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.aizuda.bpm.engine.scheduling.JobLock;
import com.aizuda.bpm.spring.autoconfigure.FlowLongProperties;
import com.aizuda.bpm.spring.event.TaskEvent;
import com.wf.entity.FlowUser;
import com.wf.service.FlowUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;

import java.util.List;
import java.util.stream.Collectors;

@Configuration
@RequiredArgsConstructor
@Slf4j
public class TestConfig {

    private final FlowLongEngine flowLongEngine;

    private final FlowUserService flowUserService;

    @Bean
    @ConditionalOnBean(TaskReminder.class)
    @ConditionalOnMissingBean
    public FlowLongScheduler springBootScheduler(FlowLongEngine flowLongEngine, FlowLongProperties properties, JobLock jobLock) {
        FlowLongScheduler scheduler = new TestFlowLongScheduler();
        scheduler.setFlowLongEngine(flowLongEngine);
        scheduler.setRemindParam(properties.getRemind());
        scheduler.setJobLock(jobLock);
        return scheduler;
    }

    /**
     * 异步任务事件监听处理
     * <p>
     * application.yml 开启  flowlong.eventing.task = true
     * </p>
     */
    @EventListener
    public void onTaskEvent(TaskEvent taskEvent) {
        log.info("当前执行任务 = {}, 执行事件 = {} ",
                taskEvent.getFlwTask().getTaskName(),
                taskEvent.getEventType().name());
        Long instanceId = taskEvent.getFlwTask().getInstanceId();
        FlwInstance instance = flowLongEngine.queryService()
                .getInstance(instanceId);
        FlwProcess process = flowLongEngine.processService()
                .getProcessById(instance.getProcessId());
        log.info("流程定义 = {} ", process.getProcessKey());
        log.info("流程名称 = {} ", process.getProcessName());

        // 根据BusinessKey和流程定义,处理业务数据
        String businessKey = instance.getBusinessKey();

        if (process.getProcessKey().equals("user")) {
            if (taskEvent.getEventType().eq(TaskEventType.start) || taskEvent.getEventType().eq(TaskEventType.recreate)) {
                flowUserService.updateById(new FlowUser()
                        .setId(Long.valueOf(businessKey))
                        .setState(1));
            } else if (taskEvent.getEventType().eq(TaskEventType.create) || taskEvent.getEventType().eq(TaskEventType.assignment)) {
                flowUserService.updateById(new FlowUser()
                        .setId(Long.valueOf(businessKey))
                        .setHandler(taskEvent.getTaskActors().stream().map(FlwTaskActor::getActorName).collect(Collectors.joining(","))));
            } else if (taskEvent.getEventType().eq(TaskEventType.revoke)) {
                flowUserService.updateById(new FlowUser()
                        .setId(Long.valueOf(businessKey))
                        .setState(0));
            } else if (taskEvent.getEventType().eq(TaskEventType.complete)) {
                ProcessModel processModel = flowLongEngine.queryService()
                        .getExtInstance(instance.getId()).model();
                List<NodeModel> nextChildNodes = ModelHelper.getNextChildNodes(flowLongEngine.getContext(), new Execution(FlowCreator.of(taskEvent.getFlwTask().getCreateId(), taskEvent.getFlwTask().getCreateBy()), null),
                        processModel.getNodeConfig(), taskEvent.getFlwTask().getTaskKey());
                if (nextChildNodes.isEmpty() || nextChildNodes.stream().noneMatch(child -> ModelHelper.checkExistApprovalNode(child))) {
                    flowUserService.updateById(new FlowUser()
                            .setId(Long.valueOf(businessKey))
                            .setState(2));
                }
            } else if (taskEvent.getEventType().eq(TaskEventType.reject)) {
                flowUserService.updateById(new FlowUser()
                        .setId(Long.valueOf(businessKey))
                        .setState(4));
            } else if (taskEvent.getEventType().eq(TaskEventType.terminate)) {
                flowUserService.updateById(new FlowUser()
                        .setId(Long.valueOf(businessKey))
                        .setState(3));
            }
        }
    }
}
