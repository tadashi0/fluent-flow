package cn.tdx.module.workflow.dal;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AccessLevel;
import lombok.Data;
import lombok.experimental.Accessors;
import lombok.experimental.FieldDefaults;

import java.util.Date;


/**
 * 流程测试实体类 flow_user
 *
 * @author chonghui.tian
 * @date 2025-04-22
 */
@Data
@Accessors(chain = true)
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonIgnoreProperties(ignoreUnknown = true)
@TableName(value = "flow_user", autoResultMap = true)
public class FlowUser {

    /**
     * 主键
     */
    @TableId(type = IdType.ASSIGN_ID)
    Long id;

    /**
     * 名字
     */
    String name;

    /**
     * 年龄
     */
    Long age;

    /**
     * 审批状态
     */
    Integer state;

    /**
     * 待处理人ID
     */
    String handler;
    /**
     * 待处理人名称
     */
    @TableField(exist = false)
    String handlerName;

    /**
     * 数据状态（0:正常;1:删除）
     */
    private Long status;

    /**
     * 创建时间
     */
    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createdTime;

    /**
     * 创建人
     */
    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createdBy;

    /**
     * 修改时间
     */
    @TableField(value = "modify_time", fill = FieldFill.INSERT_UPDATE)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date modifyTime;

    /**
     * 修改人
     */
    @TableField(value = "modify_by", fill = FieldFill.INSERT_UPDATE)
    private Long modifyBy;

    /**
     * 当前页
     */
    @TableField(exist = false)
    private Integer current = 1;
    /**
     * 页大小
     */
    @TableField(exist = false)
    private Integer size = 10;

}
