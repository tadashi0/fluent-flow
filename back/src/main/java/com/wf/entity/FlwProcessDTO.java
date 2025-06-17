package com.wf.entity;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.alibaba.fastjson2.JSON;
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
