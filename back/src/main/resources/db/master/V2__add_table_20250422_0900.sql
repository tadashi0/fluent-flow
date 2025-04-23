/*
 Navicat Premium Dump SQL

 Source Server         : 172.16.1.63
 Source Server Type    : MySQL
 Source Server Version : 50743 (5.7.43)
 Source Host           : 172.16.1.63:3306
 Source Schema         : ctg-cloud

 Target Server Type    : MySQL
 Target Server Version : 50743 (5.7.43)
 File Encoding         : 65001

 Date: 22/04/2025 17:35:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for flow_user
-- ----------------------------
DROP TABLE IF EXISTS `flow_user`;
CREATE TABLE `flow_user` (
  `id` bigint(20) NOT NULL COMMENT '主键',
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
