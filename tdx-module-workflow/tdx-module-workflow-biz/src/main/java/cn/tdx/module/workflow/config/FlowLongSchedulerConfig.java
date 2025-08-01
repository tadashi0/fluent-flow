package cn.tdx.module.workflow.config;

import com.aizuda.bpm.engine.FlowLongScheduler;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;

public class FlowLongSchedulerConfig extends FlowLongScheduler implements SchedulingConfigurer {

    @Override
    public void configureTasks(ScheduledTaskRegistrar taskRegistrar) {
        taskRegistrar.addTriggerTask(this::remind, triggerContext ->
                new CronTrigger(getRemindParam().getCron()).nextExecutionTime(triggerContext).toInstant());
    }

}
