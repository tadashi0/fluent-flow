package com.wf.entity;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.Accessors;
import lombok.experimental.FieldDefaults;

import java.util.Date;

/**
 * @author chonghui. tian
 * date 2025/4/17 18:33
 * description
 */
@Data
@Accessors(chain = true)
@FieldDefaults(level = AccessLevel.PRIVATE)
public class TodoListVO {
    // 实例ID
    Long instanceId;
    // 标题
    String title;
    //审批类型
    String processName;
    //发起人
    String startName;
    //提交时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    Date submitTime;
    //当前节点
    String currentNode;
    //任务到达时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    Date arriveTime;
    //审批状态
    Integer taskState;
}
