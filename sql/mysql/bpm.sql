DROP TABLE IF EXISTS `bpm_category`;
CREATE TABLE `bpm_category`
(
    `id`          bigint(0) NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '分类编号',
    `name`        varchar(255)    DEFAULT NULL COMMENT '分类名',
    `code`        varchar(255)    DEFAULT NULL COMMENT '分类标志',
    `description` varchar(255)    DEFAULT NULL COMMENT '分类描述',
    `status`      int(11) DEFAULT NULL COMMENT '分类状态，枚举 CommonStatusEnum',
    `sort`        int(11) DEFAULT NULL COMMENT '分类排序',
    `create_time` datetime COMMENT '创建时间',
    `update_time` datetime COMMENT '最后更新时间',
    `creator`     varchar(255) COMMENT '创建者，目前使用 SysUser 的 id 编号',
    `updater`     varchar(255) COMMENT '更新者，目前使用 SysUser 的 id 编号',
    `deleted`     tinyint(1) DEFAULT NULL COMMENT '是否删除',
    `tenant_id`   bigint NOT NULL DEFAULT 0 COMMENT '租户编号'
) ENGINE=InnoDB  COMMENT='流程分类';

DROP TABLE IF EXISTS `bpm_form`;
CREATE TABLE `bpm_form`
(
    `id`          bigint                                                         NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`        varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NOT NULL COMMENT '表单名',
    `status`      tinyint                                                        NOT NULL COMMENT '开启状态',
    `conf`        varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '表单的配置',
    `fields`      varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '表单项的数组',
    `remark`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time` datetime                                                       NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time` datetime                                                       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     bit(1)                                                         NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint                                                         NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '工作流的表单定义';


DROP TABLE IF EXISTS `bpm_oa_leave`;
CREATE TABLE `bpm_oa_leave`
(
    `id`                  bigint                                                        NOT NULL AUTO_INCREMENT COMMENT '请假表单主键',
    `user_id`             bigint                                                        NOT NULL COMMENT '申请人的用户编号',
    `type`                tinyint                                                       NOT NULL COMMENT '请假类型',
    `reason`              varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请假原因',
    `start_time`          datetime                                                      NOT NULL COMMENT '开始时间',
    `end_time`            datetime                                                      NOT NULL COMMENT '结束时间',
    `day`                 tinyint                                                       NOT NULL COMMENT '请假天数',
    `result`              tinyint                                                       NOT NULL COMMENT '请假结果',
    `process_instance_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程实例的编号',
    `creator`             varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time`         datetime                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`             varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time`         datetime                                                      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`             bit(1)                                                        NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint                                                        NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'OA 请假申请表';


DROP TABLE IF EXISTS `bpm_process_definition_info`;
CREATE TABLE `bpm_process_definition_info`
(
    `id`                      bigint      NOT NULL AUTO_INCREMENT COMMENT '编号',
    `process_definition_id`   varchar(64) NOT NULL COMMENT '流程定义的编号',
    `model_id`                varchar(64) NOT NULL COMMENT '流程模型的编号',
    `icon`                    varchar(255)         DEFAULT NULL COMMENT '图标',
    `description`             varchar(255)         DEFAULT NULL COMMENT '描述',
    `form_type`               tinyint     NOT NULL COMMENT '表单类型',
    `form_id`                 bigint NULL DEFAULT NULL COMMENT '表单编号',
    `form_conf`               varchar(1000)        DEFAULT NULL COMMENT '表单的配置',
    `form_fields`             varchar(5000)        DEFAULT NULL COMMENT '表单项的数组',
    `form_custom_create_path` varchar(255)         DEFAULT NULL COMMENT '自定义表单的提交路径',
    `form_custom_view_path`   varchar(255)         DEFAULT NULL COMMENT '自定义表单的查看路径',
    `creator`                 varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time`             datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`                 varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time`             datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`                 bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`               bigint      NOT NULL DEFAULT 0 COMMENT '租户编号',
    `visible`                 tinyint null comment '是否可见',
    `sort`                    bigint null comment '排序',
    `start_user_ids`          varchar(1000) null comment '可发起用户编号',
    `manager_user_ids`        varchar(1000) null comment '可管理用户编号',
    `simple_model`            longtext null comment 'simple设计器模型数据json格式',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'Bpm 流程定义信息表';


DROP TABLE IF EXISTS `bpm_process_expression`;
CREATE TABLE `bpm_process_expression`
(
    `id`          bigint   NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`        varchar(64)       DEFAULT NULL COMMENT '流程实例的名字',
    `status`      tinyint  NOT NULL COMMENT '流程实例的状态',
    `expression`  varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '表达式',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     bit(1)   NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流程表达式';

DROP TABLE IF EXISTS `bpm_process_instance_copy`;
CREATE TABLE `bpm_process_instance_copy`
(
    `id`                    bigint                                                       NOT NULL AUTO_INCREMENT COMMENT '编号',
    `start_user_id`         bigint                                                       NOT NULL COMMENT '发起流程的用户编号',
    `process_instance_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程实例的名字',
    `process_instance_id`   varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '流程实例的编号',
    `category`              varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '流程分类',
    `task_id`               varchar(64)                                                           DEFAULT NULL COMMENT '任务主键',
    `task_name`             varchar(64)                                                           DEFAULT NULL COMMENT '任务名称',
    `user_id`               bigint                                                       NOT NULL COMMENT '用户编号（被抄送的用户编号）',
    `creator`               varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time`           datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`               varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time`           datetime                                                     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`               bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`             bigint                                                       NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 296 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '流程抄送表';

DROP TABLE IF EXISTS `bpm_process_listener`;
CREATE TABLE `bpm_process_listener`
(
    `id`          bigint(20) NOT NULL COMMENT '主键 ID，自增',
    `name`        varchar(255)      DEFAULT NULL COMMENT '监听器名字',
    `status`      int(11) DEFAULT NULL COMMENT '状态',
    `type`        varchar(255)      DEFAULT NULL COMMENT '监听类型',
    `event`       varchar(255)      DEFAULT NULL COMMENT '监听事件',
    `value_type`  varchar(255)      DEFAULT NULL COMMENT '值类型',
    `value`       varchar(255)      DEFAULT NULL COMMENT '值',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     bit(1)   NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流程监听器';

DROP TABLE IF EXISTS `bpm_user_group`;
CREATE TABLE `bpm_user_group`
(
    `id`          bigint   NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`        varchar(30)       DEFAULT '' COMMENT '组名',
    `description` varchar(255)      DEFAULT '' COMMENT '描述',
    `status`      tinyint  NOT NULL COMMENT '状态（0正常 1停用）',
    `user_ids`    varchar(1024)     DEFAULT '0' COMMENT '成员编号数组',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     bit(1)   NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 113 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户组';
