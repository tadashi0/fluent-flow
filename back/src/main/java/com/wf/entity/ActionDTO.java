package com.wf.entity;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.core.FlowLongContext;
import com.aizuda.bpm.engine.model.NodeAssignee;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.Accessors;
import lombok.experimental.FieldDefaults;

import java.util.HashMap;
import java.util.List;

/**
 * @author chonghui. tian
 * date 2025/4/17 18:33
 * description
 */
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ActionDTO {
    // 评论意见
    String comment;

    // 抄送人列表
    List<NodeAssignee> ccUsers;

    // 转交人列表
    FlowCreator transferUsers;

    // 回退节点Key
    String reclaimNodeKey;

    // 回退节点名称
    String reclaimNodeName;

    public HashMap<String, Object> getVariable() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("comment", comment);
        if(ObjectUtils.isNotEmpty(reclaimNodeKey)){
            map.put("reclaimNodeName", reclaimNodeName);
        }
        return map;
    }
}
