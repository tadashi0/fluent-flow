package com.example.demo.entity;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AccessLevel;
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
public class AboutListVO {
    // 任务ID
    Long taskId;
    // 审批类型
    Integer performType;
    // 发起人
    String startName;
    // 提交时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    Date submitTime;
    // 结束时间
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
    Date endTime;
    // 当前节点
    String currentNode;
    // 审批状态
    Integer taskState;
    // 已耗时（毫秒）
    Long duration;
}
