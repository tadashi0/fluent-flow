package cn.tdx.module.workflow.dal;

import com.aizuda.bpm.engine.entity.FlwProcess;
import com.alibaba.fastjson2.JSONObject;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

/**
 * @author chonghui. tian
 * date 2025/5/9 18:42
 * description 流程定义扩展类
 */
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class FlwProcessDTO extends FlwProcess {
    JSONObject variable;
}
