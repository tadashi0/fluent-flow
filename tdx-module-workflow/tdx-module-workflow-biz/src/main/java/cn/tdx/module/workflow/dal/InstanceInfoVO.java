package cn.tdx.module.workflow.dal;

import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.FieldDefaults;

/**
 * @author chonghui. tian
 * date 2025/4/17 18:33
 * description
 */
@Data
@FieldDefaults(level = AccessLevel.PRIVATE)
public class InstanceInfoVO {
    // 实例ID
    Long instanceId;
    // 审批状态
    Integer taskState;
    // 当前节点
    String currentNodeKey;
}
