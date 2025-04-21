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
public class InstanceInfoVO {
    // 实例ID
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    Long instanceId;
    // 审批状态
    Integer taskState;
}
