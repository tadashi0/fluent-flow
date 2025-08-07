/*
 Navicat Premium Dump SQL

 Source Server         : 172.16.1.63
 Source Server Type    : MySQL
 Source Server Version : 50743 (5.7.43)
 Source Host           : 172.16.1.63:3306
 Source Schema         : chonghui

 Target Server Type    : MySQL
 Target Server Version : 50743 (5.7.43)
 File Encoding         : 65001

 Date: 04/07/2025 15:42:09
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for flw_ext_instance
-- ----------------------------
DROP TABLE IF EXISTS `flw_ext_instance`;
CREATE TABLE `flw_ext_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `process_id` bigint(20) NOT NULL COMMENT '流程定义ID',
  `process_name` varchar(100) DEFAULT NULL COMMENT '流程名称',
  `process_type` varchar(100) DEFAULT NULL COMMENT '流程类型',
  `model_content` text COMMENT '流程模型定义JSON内容',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_type` (`process_type`) USING HASH,
  CONSTRAINT `fk_ext_instance_id` FOREIGN KEY (`id`) REFERENCES `flw_his_instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='扩展流程实例表';

-- ----------------------------
-- Table structure for flw_his_instance
-- ----------------------------
DROP TABLE IF EXISTS `flw_his_instance`;
CREATE TABLE `flw_his_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `create_id` varchar(50) NOT NULL COMMENT '创建人ID',
  `create_by` varchar(50) NOT NULL COMMENT '创建人名称',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `process_id` bigint(20) NOT NULL COMMENT '流程定义ID',
  `parent_instance_id` bigint(20) DEFAULT NULL COMMENT '父流程实例ID',
  `priority` tinyint(1) DEFAULT NULL COMMENT '优先级',
  `instance_no` varchar(50) DEFAULT NULL COMMENT '流程实例编号',
  `business_key` varchar(100) DEFAULT NULL COMMENT '业务KEY',
  `variable` text COMMENT '变量json',
  `current_node_name` varchar(100) NOT NULL COMMENT '当前所在节点名称',
  `current_node_key` varchar(100) NOT NULL COMMENT '当前所在节点key',
  `expire_time` timestamp NULL DEFAULT NULL COMMENT '期望完成时间',
  `last_update_by` varchar(50) DEFAULT NULL COMMENT '上次更新人',
  `last_update_time` timestamp NULL DEFAULT NULL COMMENT '上次更新时间',
  `instance_state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '流程状态 -2，已暂停状态 -1，暂存待审 0，审批中 1，审批通过 2，审批拒绝 3，撤销审批 4，超时结束 5，强制终止 6，自动通过 7，自动拒绝',
  `end_time` timestamp NULL DEFAULT NULL COMMENT '结束时间',
  `duration` bigint(20) DEFAULT NULL COMMENT '处理耗时',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_his_instance_process_id` (`process_id`) USING BTREE,
  KEY `idx_his_business_key` (`business_key`) USING HASH,
  KEY `idx_his_create_id` (`create_id`) USING BTREE,
  KEY `idx_his_instance_state` (`instance_state`) USING HASH,
  CONSTRAINT `fk_his_instance_process_id` FOREIGN KEY (`process_id`) REFERENCES `flw_process` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='历史流程实例表';

-- ----------------------------
-- Table structure for flw_his_task
-- ----------------------------
DROP TABLE IF EXISTS `flw_his_task`;
CREATE TABLE `flw_his_task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `create_id` varchar(50) NOT NULL COMMENT '创建人ID',
  `create_by` varchar(50) NOT NULL COMMENT '创建人名称',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `instance_id` bigint(20) NOT NULL COMMENT '流程实例ID',
  `parent_task_id` bigint(20) DEFAULT NULL COMMENT '父任务ID',
  `call_process_id` bigint(20) DEFAULT NULL COMMENT '调用外部流程定义ID',
  `call_instance_id` bigint(20) DEFAULT NULL COMMENT '调用外部流程实例ID',
  `task_name` varchar(100) NOT NULL COMMENT '任务名称',
  `task_key` varchar(100) NOT NULL COMMENT '任务 key 唯一标识',
  `task_type` tinyint(1) NOT NULL COMMENT '任务类型',
  `perform_type` tinyint(1) DEFAULT NULL COMMENT '参与类型',
  `action_url` varchar(200) DEFAULT NULL COMMENT '任务处理的url',
  `variable` text COMMENT '变量json',
  `assignor_id` varchar(100) DEFAULT NULL COMMENT '委托人ID',
  `assignor` varchar(255) DEFAULT NULL COMMENT '委托人',
  `expire_time` timestamp NULL DEFAULT NULL COMMENT '任务期望完成时间',
  `remind_time` timestamp NULL DEFAULT NULL COMMENT '提醒时间',
  `remind_repeat` tinyint(3) NOT NULL DEFAULT '0' COMMENT '提醒次数',
  `viewed` tinyint(1) NOT NULL DEFAULT '0' COMMENT '已阅 0，否 1，是',
  `finish_time` timestamp NULL DEFAULT NULL COMMENT '任务完成时间',
  `task_state` tinyint(1) NOT NULL DEFAULT '0' COMMENT '任务状态 0，活动 1，跳转 2，完成 3，拒绝 4，撤销审批 5，超时 6，终止 7，驳回终止 8，自动完成 9，自动驳回 10，自动跳转 11，驳回跳转 12，驳回重新审批跳转 13，路由跳转',
  `duration` bigint(20) DEFAULT NULL COMMENT '处理耗时',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_his_task_instance_id` (`instance_id`) USING BTREE,
  KEY `idx_his_task_parent_task_id` (`parent_task_id`) USING BTREE,
  KEY `idx_his_task_type_id` (`task_type`,`id`),
  CONSTRAINT `fk_his_task_instance_id` FOREIGN KEY (`instance_id`) REFERENCES `flw_his_instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='历史任务表';

-- ----------------------------
-- Table structure for flw_his_task_actor
-- ----------------------------
DROP TABLE IF EXISTS `flw_his_task_actor`;
CREATE TABLE `flw_his_task_actor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `instance_id` bigint(20) NOT NULL COMMENT '流程实例ID',
  `task_id` bigint(20) NOT NULL COMMENT '任务ID',
  `actor_id` varchar(100) NOT NULL COMMENT '参与者ID',
  `actor_name` varchar(100) NOT NULL COMMENT '参与者名称',
  `actor_type` int(11) NOT NULL COMMENT '参与者类型 0，用户 1，角色 2，部门',
  `weight` int(11) DEFAULT NULL COMMENT '权重，票签任务时，该值为不同处理人员的分量比例，代理任务时，该值为 1 时为代理人',
  `agent_id` varchar(100) DEFAULT NULL COMMENT '代理人ID',
  `agent_type` int(11) DEFAULT NULL COMMENT '代理人类型 0，代理 1，被代理 2，认领角色 3，认领部门',
  `extend` text COMMENT '扩展json',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_his_task_actor_task_id` (`task_id`) USING BTREE,
  KEY `idx_actor_type_weight` (`actor_id`,`actor_type`,`weight`,`instance_id`) USING BTREE,
  CONSTRAINT `fk_his_task_actor_task_id` FOREIGN KEY (`task_id`) REFERENCES `flw_his_task` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='历史任务参与者表';

-- ----------------------------
-- Table structure for flw_instance
-- ----------------------------
DROP TABLE IF EXISTS `flw_instance`;
CREATE TABLE `flw_instance` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `create_id` varchar(50) NOT NULL COMMENT '创建人ID',
  `create_by` varchar(50) NOT NULL COMMENT '创建人名称',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `process_id` bigint(20) NOT NULL COMMENT '流程定义ID',
  `parent_instance_id` bigint(20) DEFAULT NULL COMMENT '父流程实例ID',
  `priority` tinyint(1) DEFAULT NULL COMMENT '优先级',
  `instance_no` varchar(50) DEFAULT NULL COMMENT '流程实例编号',
  `business_key` varchar(100) DEFAULT NULL COMMENT '业务KEY',
  `variable` text COMMENT '变量json',
  `current_node_name` varchar(100) NOT NULL COMMENT '当前所在节点名称',
  `current_node_key` varchar(100) NOT NULL COMMENT '当前所在节点key',
  `expire_time` timestamp NULL DEFAULT NULL COMMENT '期望完成时间',
  `last_update_by` varchar(50) DEFAULT NULL COMMENT '上次更新人',
  `last_update_time` timestamp NULL DEFAULT NULL COMMENT '上次更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_instance_process_id` (`process_id`) USING BTREE,
  CONSTRAINT `fk_instance_process_id` FOREIGN KEY (`process_id`) REFERENCES `flw_process` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='流程实例表';

-- ----------------------------
-- Table structure for flw_process
-- ----------------------------
DROP TABLE IF EXISTS `flw_process`;
CREATE TABLE `flw_process` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `create_id` varchar(50) NOT NULL COMMENT '创建人ID',
  `create_by` varchar(50) NOT NULL COMMENT '创建人名称',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `process_key` varchar(100) NOT NULL COMMENT '流程定义 key 唯一标识',
  `process_name` varchar(100) NOT NULL COMMENT '流程定义名称',
  `process_icon` varchar(255) DEFAULT NULL COMMENT '流程图标地址',
  `process_type` varchar(100) DEFAULT NULL COMMENT '关联表名',
  `process_version` int(11) NOT NULL DEFAULT '1' COMMENT '流程版本，默认 1',
  `instance_url` varchar(200) DEFAULT NULL COMMENT '实例地址',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注说明',
  `use_scope` tinyint(1) NOT NULL DEFAULT '0' COMMENT '使用范围 1，主流程 2，子流程',
  `process_state` tinyint(1) NOT NULL DEFAULT '1' COMMENT '流程状态 0，不可用 1，可用 2，历史版本',
  `model_content` text COMMENT '流程模型定义JSON内容',
  `sort` tinyint(1) DEFAULT '0' COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_process_name` (`process_name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='流程定义表';

-- ----------------------------
-- Table structure for flw_task
-- ----------------------------
DROP TABLE IF EXISTS `flw_task`;
CREATE TABLE `flw_task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `create_id` varchar(50) NOT NULL COMMENT '创建人ID',
  `create_by` varchar(50) NOT NULL COMMENT '创建人名称',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  `instance_id` bigint(20) NOT NULL COMMENT '流程实例ID',
  `parent_task_id` bigint(20) DEFAULT NULL COMMENT '父任务ID',
  `task_name` varchar(100) NOT NULL COMMENT '任务名称',
  `task_key` varchar(100) NOT NULL COMMENT '任务 key 唯一标识',
  `task_type` tinyint(1) NOT NULL COMMENT '任务类型 -1，结束节点 0，主办 1，审批 2，抄送 3，条件审批 4，条件分支 5，调用外部流程任务 6，定时器任务 7，触发器任务 8，并行分支 9，包容分支 10，转办 11，委派 12，委派归还 13，代理人任务 14，代理人归还 15，代理人协办 16，被代理人自己完成 17，拿回任务 18，待撤回历史任务 19，拒绝任务 20，跳转任务 21，驳回跳转 22，路由跳转 23，路由分支 24，驳回重新审批跳转 25，暂存待审 30，自动通过 31，自动拒绝',
  `perform_type` tinyint(1) DEFAULT NULL COMMENT '参与类型 0，发起 1，按顺序依次审批 2，会签 3，或签 4，票签 6，定时器 7，触发器 9，抄送',
  `action_url` varchar(200) DEFAULT NULL COMMENT '任务处理的url',
  `variable` text COMMENT '变量json',
  `assignor_id` varchar(100) DEFAULT NULL COMMENT '委托人ID',
  `assignor` varchar(255) DEFAULT NULL COMMENT '委托人',
  `expire_time` timestamp NULL DEFAULT NULL COMMENT '任务期望完成时间',
  `remind_time` timestamp NULL DEFAULT NULL COMMENT '提醒时间',
  `remind_repeat` tinyint(3) NOT NULL DEFAULT '0' COMMENT '提醒次数',
  `viewed` tinyint(1) NOT NULL DEFAULT '0' COMMENT '已阅 0，否 1，是',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_instance_id` (`instance_id`) USING BTREE,
  CONSTRAINT `fk_task_instance_id` FOREIGN KEY (`instance_id`) REFERENCES `flw_instance` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='任务表';

-- ----------------------------
-- Table structure for flw_task_actor
-- ----------------------------
DROP TABLE IF EXISTS `flw_task_actor`;
CREATE TABLE `flw_task_actor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `tenant_id` varchar(50) DEFAULT NULL COMMENT '租户ID',
  `instance_id` bigint(20) NOT NULL COMMENT '流程实例ID',
  `task_id` bigint(20) NOT NULL COMMENT '任务ID',
  `actor_id` varchar(100) NOT NULL COMMENT '参与者ID',
  `actor_name` varchar(100) NOT NULL COMMENT '参与者名称',
  `actor_type` int(11) NOT NULL COMMENT '参与者类型 0，用户 1，角色 2，部门',
  `weight` int(11) DEFAULT NULL COMMENT '权重，票签任务时，该值为不同处理人员的分量比例，代理任务时，该值为 1 时为代理人',
  `agent_id` varchar(100) DEFAULT NULL COMMENT '代理人ID',
  `agent_type` int(11) DEFAULT NULL COMMENT '代理人类型 0，代理 1，被代理 2，认领角色 3，认领部门',
  `extend` text COMMENT '扩展json',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_task_actor_task_id` (`task_id`) USING BTREE,
  KEY `idx_task_actor_id` (`actor_id`,`actor_type`) USING BTREE,
  CONSTRAINT `fk_task_actor_task_id` FOREIGN KEY (`task_id`) REFERENCES `flw_task` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC COMMENT='任务参与者表';

SET FOREIGN_KEY_CHECKS = 1;

-- ----------------------------
-- Table structure for flow_user
-- ----------------------------
DROP TABLE IF EXISTS `flow_user`;
CREATE TABLE `flow_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `name` varchar(255) DEFAULT NULL COMMENT '名字',
  `age` int(11) DEFAULT NULL COMMENT '年龄',
  `state` int(2) DEFAULT 0 COMMENT '审批状态',
  `status` int(1) DEFAULT 0 COMMENT '数据状态(0:正常;1:删除)',
  `handler` varchar(255) DEFAULT NULL COMMENT '待处理人',
  `created_by` int(11) DEFAULT 0 COMMENT '创建人',
  `created_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `modify_by` int(11) DEFAULT 0 COMMENT '修改人',
  `modify_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('流程中心', '', 1, 30, 0, '/flow', 'fa:medium', '', '', 0, b'1', b'1', b'1', '1', '2025-07-29 11:28:41', '1', '2025-07-29 11:38:30', b'0');
SELECT @parentId := LAST_INSERT_ID();

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('流程设置', '', 2, 1, @parentId, 'flow-setting', 'ep:setting', 'WorkFlow/setting/index', 'FlowSetting', 0, b'1', b'1', b'1', '1', '2025-07-29 11:30:28', '1', '2025-07-30 09:33:57', b'0');
SELECT @child_parentId := LAST_INSERT_ID();

INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('审批列表', '', 2, 3, @parentId, 'flow-board', 'ep:list', 'WorkFlow/center/Dashboard', 'FlowBoard', 0, b'1', b'1', b'1', '1', '2025-07-29 15:13:39', '1', '2025-07-30 09:34:05', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('流程新增', '', 2, 3, @child_parentId, 'create', '', 'Workflow/setting/ProcessCreate', 'Create', 0, b'1', b'1', b'1', '1', '2025-07-29 15:26:39', '1', '2025-07-29 15:27:03', b'1');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('新建流程', '', 2, 2, @parentId, 'flow-create', 'ep:document-add', 'WorkFlow/setting/FlowCreate', 'FlowCreate', 0, b'0', b'0', b'1', '1', '2025-07-29 19:06:32', '1', '2025-07-30 09:37:11', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('待我处理', '', 2, 4, @parentId, 'flow-todo', 'ep:stamp', 'WorkFlow/center/TodoTasks', 'FlowTodo', 0, b'1', b'1', b'1', '1', '2025-07-29 19:17:46', '1', '2025-07-30 14:03:48', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('已处理的', '', 2, 5, @parentId, 'flow-done', 'ep:avatar', 'WorkFlow/center/DoneTasks', 'FlowDone', 0, b'1', b'1', b'1', '1', '2025-07-29 19:18:21', '1', '2025-07-30 14:03:55', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('我发起的', '', 2, 6, @parentId, 'flow-submit', 'ep:checked', 'WorkFlow/center/SubmitTasks', 'FlowSubmit', 0, b'1', b'1', b'1', '1', '2025-07-29 19:18:49', '1', '2025-07-30 14:03:21', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('抄送我的', '', 2, 7, @parentId, 'flow-about', 'ep:promotion', 'WorkFlow/center/AboutTasks', 'FlowAbout', 0, b'1', b'1', b'1', '1', '2025-07-29 19:19:15', '1', '2025-07-30 14:04:29', b'0');
INSERT INTO `system_menu` (`name`, `permission`, `type`, `sort`, `parent_id`, `path`, `icon`, `component`, `component_name`, `status`, `visible`, `keep_alive`, `always_show`, `creator`, `create_time`, `updater`, `update_time`, `deleted`) VALUES ('工作流测试模块', '', 2, 0, @parentId, 'flow-user', 'ep:compass', 'WorkFlow/test/index', 'FlowUser', 0, b'1', b'1', b'1', '1', '2025-07-30 15:50:55', '1', '2025-07-30 15:51:04', b'0');