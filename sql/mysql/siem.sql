SET NAMES utf8mb4;
SET
FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for siem_content_fill
-- ----------------------------
DROP TABLE IF EXISTS `siem_content_fill`;
CREATE TABLE `siem_content_fill`
(
    `id`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id` varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '采集器id',
    `sort`       int(11) NULL DEFAULT NULL COMMENT '序号',
    `name`       varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '填充类型名称',
    `type`       varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '填充类型(0:静态填充,1:动态填充,2:日志过滤)',
    create_time  datetime null comment '创建时间',
    update_time  datetime null comment '最后更新时间',
    creator      varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater      varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted      tinyint(1) default 0 null comment '是否删除',
    tenant_id    bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '内容填充'
  ROW_FORMAT = Dynamic;

DROP TABLE IF EXISTS `siem_content_fill_condition`;
CREATE TABLE `siem_content_fill_condition`
(
    `id`             varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id`     varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '采集器id',
    `fill_id`        varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '内容填充id',
    `fill_rule_id`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '内容填充详细规则id',
    `sort`           int(11) NULL DEFAULT NULL COMMENT '序号',
    `type`           varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '类型',
    `operate`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '操作',
    `fill_condition` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '条件',
    create_time      datetime null comment '创建时间',
    update_time      datetime null comment '最后更新时间',
    creator          varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater          varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted          tinyint(1) default 0 null comment '是否删除',
    tenant_id        bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '内容填充详细字段条件'
  ROW_FORMAT = Dynamic;


DROP TABLE IF EXISTS `siem_content_fill_field`;
CREATE TABLE `siem_content_fill_field`
(
    `id`           varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id`   varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '采集器id',
    `fill_id`      varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '内容填充id',
    `fill_rule_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '内容填充详细规则id',
    `sort`         int(11) NULL DEFAULT NULL COMMENT '序号',
    `field_value`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段名',
    `fill_value`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '填充值',
    create_time    datetime null comment '创建时间',
    update_time    datetime null comment '最后更新时间',
    creator        varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater        varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted        tinyint(1) default 0 null comment '是否删除',
    tenant_id      bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '内容填充详细字段信息'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of siem_content_fill_field
-- ----------------------------

-- ----------------------------
-- Table structure for siem_content_fill_rule
-- ----------------------------
DROP TABLE IF EXISTS `siem_content_fill_rule`;
CREATE TABLE `siem_content_fill_rule`
(
    `id`          varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '采集器id',
    `fill_id`     varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '内容填充id',
    `sort`        int(11) NULL DEFAULT NULL COMMENT '序号',
    `name`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '填充规则名称',
    `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '描述',
    create_time   datetime null comment '创建时间',
    update_time   datetime null comment '最后更新时间',
    creator       varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater       varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted       tinyint(1) default 0 null comment '是否删除',
    tenant_id     bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '内容填充详细规则'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of siem_content_fill_rule
-- ----------------------------

-- ----------------------------
-- Table structure for siem_content_transponder
-- ----------------------------
DROP TABLE IF EXISTS `siem_content_transponder`;
CREATE TABLE `siem_content_transponder`
(
    `id`           varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id`   varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '采集器id',
    `sort`         int(11) NULL DEFAULT NULL COMMENT '序号',
    `data_type`    varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT 'all' COMMENT '数据类型(成功:success失败:error全部:all)',
    `type`         varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '转发器类型(udp,es,kafka)',
    `address`      varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '转发器地址',
    `port`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '转发器端口',
    `separate`     varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分隔符',
    `index_format` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '索引格式',
    `time_field`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '时间字段',
    `auth`         tinyint(1) NULL DEFAULT 0 COMMENT '是否开启身份认证',
    `username`     varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '用户名',
    `password`     varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '密码',
    `topic`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '队列名',
    create_time    datetime null comment '创建时间',
    update_time    datetime null comment '最后更新时间',
    creator        varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater        varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted        tinyint(1) default 0 null comment '是否删除',
    tenant_id      bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '转发器'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of siem_content_transponder
-- ----------------------------
DROP TABLE IF EXISTS `siem_dict_type`;
create table siem_dict_type
(
    id           bigint auto_increment comment '字典主键'
        primary key,
    name         varchar(100) default ''                not null comment '字典名称',
    type         varchar(100) default ''                not null comment '字典类型',
    status       tinyint      default 0                 not null comment '状态（0正常 1停用）',
    remark       varchar(500) null comment '备注',
    creator      varchar(64)  default '' null comment '创建者',
    create_time  datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updater      varchar(64)  default '' null comment '更新者',
    update_time  datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    deleted      bit          default b'0'              not null comment '是否删除',
    deleted_time datetime null comment '删除时间',
    tenant_id    bigint       default 0                 not null comment '租户编号'
) comment '字典类型表' collate = utf8mb4_unicode_ci;
-- auto-generated definition
DROP TABLE IF EXISTS `siem_dict_data`;
create table siem_dict_data
(
    id          bigint auto_increment comment '字典编码'
        primary key,
    sort        int          default 0                 not null comment '字典排序',
    label       varchar(100) default ''                not null comment '字典标签',
    value       varchar(100) default ''                not null comment '字典键值',
    dict_type   varchar(100) default ''                not null comment '字典类型',
    status      tinyint      default 0                 not null comment '状态（0正常 1停用）',
    color_type  varchar(100) default '' null comment '颜色类型',
    css_class   varchar(100) default '' null comment 'css 样式',
    remark      varchar(500) null comment '备注',
    creator     varchar(64)  default '' null comment '创建者',
    create_time datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updater     varchar(64)  default '' null comment '更新者',
    update_time datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    deleted     bit          default b'0'              not null comment '是否删除',
    tenant_id   bigint       default 0                 not null comment '租户编号'
) comment 'siem字典数据表' collate = utf8mb4_unicode_ci;

-- ----------------------------
-- Table structure for siem_field
-- ----------------------------
DROP TABLE IF EXISTS `siem_field`;
CREATE TABLE `siem_field`
(
    `id`              varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `sort`            int(11) NULL DEFAULT NULL COMMENT '序号',
    `name`            varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段名称',
    `alias`           varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段别名',
    `dictionary`      varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字典',
    `default_value`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '默认值',
    `important_field` tinyint(1) NULL DEFAULT 0 COMMENT '是否重要字段',
    `built_in_field`  tinyint(1) NULL DEFAULT 0 COMMENT '是否为系统内置字段',
    create_time       datetime null comment '创建时间',
    update_time       datetime null comment '最后更新时间',
    creator           varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater           varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted           tinyint(1) default 0 null comment '是否删除',
    tenant_id         bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '字段管理'
  ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for siem_field_processing
-- ----------------------------
DROP TABLE IF EXISTS `siem_field_processing`;
CREATE TABLE `siem_field_processing`
(
    `id`                                varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `rule_id`                           varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '解析规则id',
    `field_id`                          varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段id',
    `original_value`                    varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '原始值',
    `target_value`                      varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '目标值',
    `regular_matching_expression`       longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '正则表达式',
    `regular_target_value`              varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '目的值',
    `quadratic_analytic_regularization` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '二次解析的正则',
    create_time                         datetime null comment '创建时间',
    update_time                         datetime null comment '最后更新时间',
    creator                             varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater                             varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted                             tinyint(1) default 0 null comment '是否删除',
    tenant_id                           bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '解析规则对应字段二次处理'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of siem_field_processing
-- ----------------------------

-- ----------------------------
-- Table structure for siem_monitor
-- ----------------------------
DROP TABLE IF EXISTS `siem_monitor`;
CREATE TABLE `siem_monitor`
(
    `id`              varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `name`            varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
    `port`            varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '监听端口',
    `type`            varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '监听类型',
    `thread_number`   varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '1' COMMENT '线程数',
    `description`     text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '描述',
    `prefiltration`   text CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '日志预过滤,多个使用,隔开',
    `resolution_type` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '解析类型(正则:regular,json,分隔符:separator)',
    `resolution_rule` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '解析规则,规则id,多个使用,隔开',
    `is_enable`       tinyint(1) NULL DEFAULT 1 COMMENT '是否启用',
    create_time       datetime null comment '创建时间',
    update_time       datetime null comment '最后更新时间',
    creator           varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater           varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted           tinyint(1) default 0 null comment '是否删除',
    tenant_id         bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '监听器管理'
  ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for siem_monitor_log
-- ----------------------------
DROP TABLE IF EXISTS `siem_monitor_log`;
CREATE TABLE `siem_monitor_log`
(
    `id`                 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `monitor_id`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '采集器ID',
    `receive_data_total` double NULL DEFAULT NULL COMMENT '接收数据总数',
    `parsed_success`     double NULL DEFAULT NULL COMMENT '解析成功数量',
    `parsed_error`       double NULL DEFAULT NULL COMMENT '解析失败数量',
    `whitelist_ignored`  double NULL DEFAULT NULL COMMENT '白名单忽略',
    `init_time`          timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP (0) COMMENT '启动时间',
    `last_time`          timestamp(0) NULL DEFAULT CURRENT_TIMESTAMP (0) COMMENT '最后一次接收时间',
    create_time          datetime null comment '创建时间',
    update_time          datetime null comment '最后更新时间',
    creator              varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater              varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted              tinyint(1) default 0 null comment '是否删除',
    tenant_id            bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '监听器统计'
  ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for siem_rule
-- ----------------------------
DROP TABLE IF EXISTS `siem_rule`;
CREATE TABLE `siem_rule`
(
    `id`                  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT 'ID',
    `group_id`            bigint(20) NULL DEFAULT NULL COMMENT '分组id',
    `name`                varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '名称',
    `resolution_type`     varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '解析类型(正则:regular,json,分隔符:separator)',
    `code`                varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '编码方式(utf-8,gbk,gb-2312)',
    `description`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
    `log_sample`          longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '日志样本',
    `parsing_expressions` longtext CHARACTER SET utf8 COLLATE utf8_general_ci NULL COMMENT '解析表达式',
    status                tinyint(1) null comment '状态',
    create_time           datetime null comment '创建时间',
    update_time           datetime null comment '最后更新时间',
    creator               varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater               varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted               tinyint(1) default 0 null comment '是否删除',
    tenant_id             bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '解析规则表'
  ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for siem_rule_binding
-- ----------------------------
DROP TABLE IF EXISTS `siem_rule_binding`;
CREATE TABLE `siem_rule_binding`
(
    `id`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `rule_id`   varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '解析规则id',
    `device_ip` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '设备ip',
    create_time datetime null comment '创建时间',
    update_time datetime null comment '最后更新时间',
    creator     varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater     varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted     tinyint(1) default 0 null comment '是否删除',
    tenant_id   bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '规则绑定设备IP'
  ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for siem_rule_field
-- ----------------------------
DROP TABLE IF EXISTS `siem_rule_field`;
CREATE TABLE `siem_rule_field`
(
    `id`                 varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '主键Id',
    `rule_id`            varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci  NOT NULL COMMENT '解析规则id',
    `sort`               int(11) NULL DEFAULT NULL COMMENT '序号',
    `name`               varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段名称',
    `alias`              varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字段别名',
    `dictionary`         varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '字典',
    `default_value`      varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '默认值',
    `important_field`    tinyint(1) NULL DEFAULT 0 COMMENT '是否重要字段',
    `built_in_field`     tinyint(1) NULL DEFAULT 0 COMMENT '是否为系统内置字段',
    `index_num`          varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '解析值',
    `special_conversion` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '特殊转换(Base64解码:64decode,Base64编码:64encoder,IP转换:ipConvert,毫秒补齐:completion,日期转换:dateConversion)',
    `time_format`        varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '时间格式化',
    `processing_mode`    varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '处理模式(值匹配:value,正则匹配:regular,二次解析:analysis)',
    create_time          datetime null comment '创建时间',
    update_time          datetime null comment '最后更新时间',
    creator              varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater              varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted              tinyint(1) default 0 null comment '是否删除',
    tenant_id            bigint default 0                                        not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '解析规则对应字段'
  ROW_FORMAT = Dynamic;


-- ----------------------------
-- Table structure for siem_rule_group
-- ----------------------------
DROP TABLE IF EXISTS `siem_rule_group`;
CREATE TABLE `siem_rule_group`
(
    `id`            int(11) NOT NULL AUTO_INCREMENT COMMENT '主键Id',
    `name`          varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '分组名称',
    `parent_id`     varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '父级分组',
    `description`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '描述',
    `device_type`   varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '设备；类型',
    `manufacturer`  varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '厂商',
    `model_version` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '型号版本',
    create_time     datetime null comment '创建时间',
    update_time     datetime null comment '最后更新时间',
    creator         varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater         varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted         tinyint(1) default 0 null comment '是否删除',
    tenant_id       bigint default 0 not null comment '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  AUTO_INCREMENT = 32
  CHARACTER SET = utf8
  COLLATE = utf8_general_ci COMMENT = '规则组'
  ROW_FORMAT = Dynamic;



DROP TABLE IF EXISTS `siem_usecase_rule`;
create table siem_usecase_rule
(
    rule_id               int auto_increment comment 'ID'
        primary key,
    group_id              bigint null comment '类型id',
    name                  varchar(50) null comment '规则名称',
    index_id              bigint null comment '数据表名ID',
    conditions            text null comment '条件',
    is_enable             int          default 0 null comment '0:未启用,1::启用',
    query_value           int(10) null comment '查询时间范围',
    query_type            varchar(1)   default 'm' null comment '查询时间范围类型',
    count_number          int(10) null comment '统计次数',
    same_fields           text null comment '相同字段',
    different_fields      text null comment '不同字段',
    interval_value        int(10) null comment '运行频率间隔',
    interval_type         varchar(1)   default 'm' null comment '运行频率间隔时间类型s秒m分d天',
    is_trigger_control    tinyint(1) default 0 null comment '是否配置触发间隔',
    trigger_control_value int(10) null comment '触发间隔时间',
    trigger_control_count int(10) null comment '触发次数',
    trigger_control_type  varchar(1)   default 'm' null comment '触发间隔时间类型',
    is_delay              tinyint(1) default 0 null comment '是否配置延迟',
    delay_value           int(10) default 0 null comment '延迟时间',
    delay_type            varchar(1)   default 's' null comment '延迟时间类型',
    actions               text null comment '动作',
    description           varchar(255) default '' null comment '描述',
    frequency_type        varchar(255) null comment '执行频率类型',
    frequency_value       varchar(255) null comment '执行频率值',
    type                  varchar(255) null comment '定时任务类型',
    cron_expression       varchar(255) null comment 'cron表达式',
    retry_count           bigint       default 0 not null comment '重试次数',
    retry_interval        bigint       default 0 null comment '重试间隔',
    monitor_timeout       bigint null comment '监控超时时间 单位：毫秒',
    create_time           datetime null comment '创建时间',
    update_time           datetime null comment '最后更新时间',
    creator               varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater               varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted               tinyint(1) default 0 null comment '是否删除',
    tenant_id             bigint       default 0 not null comment '租户编号'
) comment '处理规则表' charset = utf8;

DROP TABLE IF EXISTS `siem_usecase_rule_actions`;
create table siem_usecase_rule_actions
(
    id              int auto_increment comment 'ID'
        primary key,
    rule_id         bigint null comment '规则id',
    action          varchar(255) null comment '动作',
    dictionary_type text null comment '字典的key',
    field           varchar(255) null comment '字段',
    field_text      varchar(255) null comment '字段的回显',
    form_type       varchar(255) null comment '字段所属form类型',
    value           varchar(255) null comment '字段值',
    value_text      text null comment '字段值的回显',
    create_time     datetime null comment '创建时间',
    update_time     datetime null comment '最后更新时间',
    creator         varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater         varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted         tinyint(1) default 0 null comment '是否删除',
    tenant_id       bigint default 0 not null comment '租户编号'
) comment '规则动作表' charset = utf8;

DROP TABLE IF EXISTS `siem_usecase_rule_group`;
create table siem_usecase_rule_group
(
    id          int auto_increment comment '主键Id'
        primary key,
    name        varchar(255) null comment '分组名称',
    parent_id   varchar(255) default '0' null comment '父级分组',
    create_time datetime null comment '创建时间',
    update_time datetime null comment '最后更新时间',
    creator     varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater     varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted     tinyint(1) default 0 null comment '是否删除',
    tenant_id   bigint       default 0 not null comment '租户编号'
) comment '规则组';


DROP TABLE IF EXISTS `siem_usecase_rule_job_log`;
create table siem_usecase_rule_job_log
(
    job_log_id     bigint auto_increment comment '任务日志ID'
        primary key,
    job_name       varchar(64)             not null comment '任务名称',
    job_group      varchar(64)             not null comment '任务组名',
    invoke_target  varchar(500)            not null comment '调用目标字符串',
    job_message    varchar(500) null comment '日志信息',
    status         char          default '0' null comment '执行状态（0正常 1失败）',
    exception_info varchar(2000) default '' null comment '异常信息',
    rule_id        bigint null comment '规则id',
    create_time    datetime null comment '创建时间',
    update_time    datetime null comment '最后更新时间',
    creator        varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater        varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted        tinyint(1) default 0 null comment '是否删除',
    tenant_id      bigint        default 0 not null comment '租户编号'
) comment 'usecase运行记录';


DROP TABLE IF EXISTS `siem_usecase_rule_version`;
create table siem_usecase_rule_version
(
    id                    int auto_increment comment 'ID'
        primary key,
    version               int          default 1 not null comment '版本号',
    opt_type              varchar(64)            not null comment '操作1.新增2修改3删除4回滚',
    rule_id               bigint                 not null comment 'ID',
    group_id              bigint null comment '类型id',
    name                  varchar(50) null comment '规则名称',
    index_id              bigint null comment '数据表名ID',
    is_enable             int          default 0 null comment '0:未启用,1::启用',
    conditions            text null comment '条件',
    query_value           int(10) null comment '查询时间范围',
    query_type            varchar(1)   default 'm' null comment '查询时间范围类型',
    count_number          int(10) null comment '统计次数',
    same_fields           text null comment '相同字段',
    different_fields      text null comment '不同字段',
    interval_value        int(10) null comment '运行频率间隔',
    interval_type         varchar(1)   default 'm' null comment '运行频率间隔时间类型s秒m分d天',
    is_trigger_control    tinyint(1) default 0 null comment '是否配置触发间隔',
    trigger_control_value int(10) null comment '触发间隔时间',
    trigger_control_count int(10) null comment '触发次数',
    trigger_control_type  varchar(1)   default 'm' null comment '触发间隔时间类型',
    is_delay              tinyint(1) default 0 null comment '是否配置延迟',
    delay_value           int(10) default 0 null comment '延迟时间',
    delay_type            varchar(1)   default 's' null comment '延迟时间类型',
    actions               text null comment '动作',
    description           varchar(255) default '' null comment '描述',
    frequency_type        varchar(255) null comment '执行频率类型',
    frequency_value       varchar(255) null comment '执行频率值',
    job_id                int null comment '定时任务id',
    create_time           datetime null comment '创建时间',
    update_time           datetime null comment '最后更新时间',
    creator               varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater               varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted               tinyint(1) default 0 null comment '是否删除',
    tenant_id             bigint       default 0 not null comment '租户编号'
) comment '处理规则版本' charset = utf8;

DROP TABLE IF EXISTS `siem_usecase_rule_version_actions`;
create table siem_usecase_rule_version_actions
(
    id              int auto_increment comment 'ID'
        primary key,
    rule_id         bigint null comment '规则id',
    version_id      bigint null comment '版本id',
    action          varchar(255) null comment '动作',
    dictionary_type text null comment '字典的key',
    field           varchar(255) null comment '字段',
    field_text      varchar(255) null comment '字段的回显',
    form_type       varchar(255) null comment '字段所属form类型',
    value           varchar(255) null comment '字段值',
    value_text      text null comment '字段值的回显',
    create_time     datetime null comment '创建时间',
    update_time     datetime null comment '最后更新时间',
    creator         varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater         varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted         tinyint(1) default 0 null comment '是否删除',
    tenant_id       bigint default 0 not null comment '租户编号'
) comment '版本规则动作表' charset = utf8;


DROP TABLE IF EXISTS `siem_usecase_datasource`;
create table siem_usecase_datasource
(
    id          int auto_increment comment 'ID'
        primary key,
    type        varchar(255)     not null comment '类型',
    db_name      varchar(255) null comment '数据库类型',
    driver_class_name  varchar(255) null comment '数据库的driverClass',
    address     varchar(255) null comment '地址(ip:端口)',
    is_auth     tinyint(1) default 1 null comment '认证',
    user        varchar(255) null comment '账号',
    password    varchar(255) null comment '密码',
    index_name  varchar(255) null comment '索引名称',
    filed_name  varchar(255) null comment '索引名称/表',
    create_time datetime null comment '创建时间',
    update_time datetime null comment '最后更新时间',
    creator     varchar(255) null comment '创建者，目前使用 SysUser 的 id 编号',
    updater     varchar(255) null comment '更新者，目前使用 SysUser 的 id 编号',
    deleted     tinyint(1) default 0 null comment '是否删除',
    tenant_id   bigint default 0 not null comment '租户编号'
) comment 'usecase数据源' charset = utf8;

SET
FOREIGN_KEY_CHECKS = 1;
