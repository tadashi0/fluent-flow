package com.example.demo.config;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.FlowLongScheduler;
import com.aizuda.bpm.engine.TaskReminder;
import com.aizuda.bpm.engine.entity.FlwInstance;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.engine.scheduling.JobLock;
import com.aizuda.bpm.spring.autoconfigure.FlowLongProperties;
import com.aizuda.bpm.spring.event.TaskEvent;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;

@Configuration
@RequiredArgsConstructor
public class TestConfig {

    private final FlowLongEngine flowLongEngine;

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
        System.err.println("当前执行任务 = " + taskEvent.getFlwTask().getTaskName() +
                " ，执行事件 = " + taskEvent.getEventType().name());
        Long instanceId = taskEvent.getFlwTask().getInstanceId();
        FlwInstance instance = flowLongEngine.queryService()
                .getInstance(instanceId);
        FlwProcess process = flowLongEngine.processService()
                .getProcessById(instance.getProcessId());
        System.err.println("流程定义 = " + process.getProcessKey());
        System.err.println("流程名称 = " + process.getProcessName());
        System.err.println("实例模型 = " + taskEvent.getNodeModel());


        String businessKey = instance.getBusinessKey();
        // 根据BusinessKey和流程定义,处理业务数据

        // 如果taskEvent.getNodeModel是null, 那么就说明这个流程走完了
    }
}
