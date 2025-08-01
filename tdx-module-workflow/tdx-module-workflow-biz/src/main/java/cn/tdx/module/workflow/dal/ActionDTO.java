package cn.tdx.module.workflow.dal;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.model.NodeAssignee;
import lombok.AccessLevel;
import lombok.Data;
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

    // 加签方式
    Boolean signType;

    // 加签节点名称
    String nodeName;

    // 加签人列表
    List<NodeAssignee> counterSignUsers;

    public HashMap<String, Object> getVariable() {
        HashMap<String, Object> map = new HashMap<>();
        map.put("comment", comment);
        if(ObjectUtils.isNotEmpty(reclaimNodeKey)){
            map.put("reclaimNodeName", reclaimNodeName);
        }
        return map;
    }
}
