package com.wf.config;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.FlowLongScheduler;
import com.aizuda.bpm.engine.TaskReminder;
import com.aizuda.bpm.engine.assist.DateUtils;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.FlowLongContext;
import com.aizuda.bpm.engine.core.enums.TaskType;
import com.aizuda.bpm.engine.entity.FlwTask;
import com.aizuda.bpm.engine.model.NodeModel;
import com.aizuda.bpm.engine.model.ProcessModel;
import com.aizuda.bpm.engine.scheduling.JobLock;
import com.aizuda.bpm.spring.autoconfigure.FlowLongProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.stereotype.Component;

import java.util.Date;
import java.util.Objects;

/**
 * 注入自定义任务提醒处理类
 * 注解 EnableScheduling 必须启动
 */
@Component
@EnableScheduling
@RequiredArgsConstructor
@Slf4j
public class TaskReminderConfig implements TaskReminder {

    // @Bean
    // @ConditionalOnBean(TaskReminder.class)
    // @ConditionalOnMissingBean
    // public FlowLongScheduler springBootScheduler(FlowLongEngine flowLongEngine, FlowLongProperties properties, JobLock jobLock) {
    //     FlowLongScheduler scheduler = new FlowLongSchedulerConfig();
    //     scheduler.setFlowLongEngine(flowLongEngine);
    //     scheduler.setRemindParam(properties.getRemind());
    //     scheduler.setJobLock(jobLock);
    //     return scheduler;
    // }

    @Override
    public Date remind(FlowLongContext context, Long instanceId, FlwTask flwTask) {
        Date remindTime = flwTask.getRemindTime();

        if (null != remindTime) {

            System.out.println("测试提醒：" + instanceId);
        }

        // 一天后继续提醒，直到用户处理完
        return DateUtils.toDate(DateUtils.now().plusDays(1));
    }
}
