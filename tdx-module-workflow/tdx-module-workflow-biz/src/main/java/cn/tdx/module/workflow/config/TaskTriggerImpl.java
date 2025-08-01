package cn.tdx.module.workflow.config;

import com.aizuda.bpm.engine.TaskTrigger;
import com.aizuda.bpm.engine.core.Execution;
import com.aizuda.bpm.engine.model.NodeModel;

import java.util.function.Function;

public class TaskTriggerImpl implements TaskTrigger {

    @Override
    public boolean execute(NodeModel nodeModel, Execution execution, Function<Execution, Boolean> finish) {
        System.out.println("执行了触发器 args = " + nodeModel.getExtendConfig().get("args"));
        return finish.apply(execution);
    }
}