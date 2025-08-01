/*
 Navicat Premium Data Transfer

 Source Server         : 99
 Source Server Type    : MySQL
 Source Server Version : 80024
 Source Host           : 47.97.10.99:3306
 Source Schema         : dlyg_cloud

 Target Server Type    : MySQL
 Target Server Version : 80024
 File Encoding         : 65001

 Date: 29/11/2024 10:53:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for crm_business
-- ----------------------------
DROP TABLE IF EXISTS `crm_business`;
CREATE TABLE `crm_business`  (
                                 `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                 `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商机名称',
                                 `customer_id` bigint(0) NOT NULL COMMENT '客户编号',
                                 `follow_up_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '跟进状态',
                                 `contact_last_time` datetime(0) NULL DEFAULT NULL COMMENT '最后跟进时间',
                                 `contact_next_time` datetime(0) NULL DEFAULT NULL COMMENT '下次联系时间',
                                 `owner_user_id` bigint(0) NOT NULL COMMENT '负责人的用户编号',
                                 `status_type_id` bigint(0) NOT NULL COMMENT '商机状态组编号',
                                 `status_id` bigint(0) NOT NULL COMMENT '商机状态编号',
                                 `end_status` int(0) NULL DEFAULT NULL COMMENT '结束状态',
                                 `end_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '结束时的备注',
                                 `deal_time` datetime(0) NULL DEFAULT NULL COMMENT '预计成交日期',
                                 `total_product_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '产品总金额，单位：元',
                                 `discount_percent` decimal(10, 2) NULL DEFAULT NULL COMMENT '整单折扣，百分比',
                                 `total_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '商机总金额，单位：元',
                                 `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                                 `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                 `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                 `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                 `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                 `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                 `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                 PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM商机表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_business_product
-- ----------------------------
DROP TABLE IF EXISTS `crm_business_product`;
CREATE TABLE `crm_business_product`  (
                                         `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                         `business_id` bigint(0) NOT NULL COMMENT '商机编号',
                                         `product_id` bigint(0) NOT NULL COMMENT '产品编号',
                                         `product_price` decimal(10, 2) NOT NULL COMMENT '产品单价，单位：元',
                                         `business_price` decimal(10, 2) NOT NULL COMMENT '商机价格，单位：元',
                                         `count` decimal(10, 2) NOT NULL COMMENT '数量',
                                         `total_price` decimal(10, 2) NOT NULL COMMENT '总计价格，单位：元，totalPrice = business_price * count',
                                         `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM商机产品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_business_status
-- ----------------------------
DROP TABLE IF EXISTS `crm_business_status`;
CREATE TABLE `crm_business_status`  (
                                        `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                        `type_id` bigint(0) NOT NULL COMMENT '状态类型编号',
                                        `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态名',
                                        `percent` int(0) NOT NULL COMMENT '赢单率，百分比',
                                        `sort` int(0) NOT NULL COMMENT '排序',
                                        `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                        `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                        `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM商机状态表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_business_status_type
-- ----------------------------
DROP TABLE IF EXISTS `crm_business_status_type`;
CREATE TABLE `crm_business_status_type`  (
                                             `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                             `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '状态类型名',
                                             `dept_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '使用的部门编号',
                                             `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                             `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                             `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                             `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                             `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                             `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                             PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM商机状态类型表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_clue
-- ----------------------------
DROP TABLE IF EXISTS `crm_clue`;
CREATE TABLE `crm_clue`  (
                             `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
                             `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '线索名称',
                             `follow_up_status` tinyint(1) NULL DEFAULT 0 COMMENT '跟进状态',
                             `contact_last_time` datetime(0) NULL DEFAULT NULL COMMENT '最后跟进时间',
                             `contact_last_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '最后跟进内容',
                             `contact_next_time` datetime(0) NULL DEFAULT NULL COMMENT '下次联系时间',
                             `owner_user_id` bigint(0) NULL DEFAULT NULL COMMENT '负责人的用户编号',
                             `transform_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '转化状态',
                             `customer_id` bigint(0) NULL DEFAULT NULL COMMENT '客户编号',
                             `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
                             `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
                             `qq` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'QQ',
                             `wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'wechat',
                             `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'email',
                             `area_id` int(0) NULL DEFAULT NULL COMMENT '所在地，关联 Area 的 id 字段',
                             `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
                             `industry_id` int(0) NULL DEFAULT NULL COMMENT '所属行业，对应字典 CRM_CUSTOMER_INDUSTRY',
                             `level` int(0) NULL DEFAULT NULL COMMENT '客户等级，对应字典 CRM_CUSTOMER_LEVEL',
                             `source` int(0) NULL DEFAULT NULL COMMENT '客户来源，对应字典 CRM_CUSTOMER_SOURCE',
                             `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                             `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                             `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                             `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                             `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                             `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                             `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                             PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM线索表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_contact
-- ----------------------------
DROP TABLE IF EXISTS `crm_contact`;
CREATE TABLE `crm_contact`  (
                                `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '联系人姓名',
                                `customer_id` bigint(0) NOT NULL COMMENT '客户编号',
                                `contact_last_time` datetime(0) NULL DEFAULT NULL COMMENT '最后跟进时间',
                                `contact_last_content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '最后跟进内容',
                                `contact_next_time` datetime(0) NULL DEFAULT NULL COMMENT '下次联系时间',
                                `owner_user_id` bigint(0) NULL DEFAULT NULL COMMENT '负责人用户编号',
                                `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
                                `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
                                `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电子邮箱',
                                `qq` bigint(0) NULL DEFAULT NULL COMMENT 'QQ',
                                `wechat` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '微信',
                                `area_id` int(0) NULL DEFAULT NULL COMMENT '所在地',
                                `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
                                `sex` int(0) NULL DEFAULT NULL COMMENT '性别',
                                `master` tinyint(1) NULL DEFAULT NULL COMMENT '是否关键决策人',
                                `post` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '职位',
                                `parent_id` bigint(0) NULL DEFAULT NULL COMMENT '直属上级',
                                `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                                `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM联系人表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_contact_business
-- ----------------------------
DROP TABLE IF EXISTS `crm_contact_business`;
CREATE TABLE `crm_contact_business`  (
                                         `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                         `contact_id` bigint(0) NOT NULL COMMENT '联系人编号',
                                         `business_id` bigint(0) NOT NULL COMMENT '商机编号',
                                         `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM联系人商机关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_contract
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract`;
CREATE TABLE `crm_contract`  (
                                 `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '合同编号',
                                 `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同名称',
                                 `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '合同编号',
                                 `customer_id` bigint(0) NOT NULL COMMENT '客户编号',
                                 `business_id` bigint(0) NULL DEFAULT NULL COMMENT '商机编号段',
                                 `contact_last_time` datetime(0) NULL DEFAULT NULL COMMENT '最后跟进时间',
                                 `owner_user_id` bigint(0) NULL DEFAULT NULL COMMENT '负责人的用户编号',
                                 `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '工作流编号',
                                 `audit_status` int(0) NOT NULL DEFAULT 0 COMMENT '审批状态',
                                 `order_date` datetime(0) NOT NULL COMMENT '下单日期',
                                 `start_time` datetime(0) NULL DEFAULT NULL COMMENT '开始时间',
                                 `end_time` datetime(0) NULL DEFAULT NULL COMMENT '结束时间',
                                 `total_product_price` decimal(19, 2) NULL DEFAULT NULL COMMENT '产品总金额，单位：元',
                                 `discount_percent` decimal(19, 2) NULL DEFAULT NULL COMMENT '整单折扣',
                                 `total_price` decimal(19, 2) NULL DEFAULT NULL COMMENT '合同总金额，单位：分',
                                 `sign_contact_id` bigint(0) NULL DEFAULT NULL COMMENT '客户签约人',
                                 `sign_user_id` bigint(0) NULL DEFAULT NULL COMMENT '公司签约人',
                                 `remark` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '备注',
                                 `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                 `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                 `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                 `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                 `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                 `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                 PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM合同表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_contract_config
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract_config`;
CREATE TABLE `crm_contract_config`  (
                                        `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                        `notify_enabled` tinyint(1) NOT NULL COMMENT '是否开启提前提醒',
                                        `notify_days` int(0) NOT NULL COMMENT '提前提醒天数',
                                        `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                        `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                        `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM合同配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_contract_product
-- ----------------------------
DROP TABLE IF EXISTS `crm_contract_product`;
CREATE TABLE `crm_contract_product`  (
                                         `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                         `contract_id` bigint(0) NOT NULL COMMENT '合同编号',
                                         `product_id` bigint(0) NOT NULL COMMENT '产品编号',
                                         `product_price` decimal(19, 2) NOT NULL COMMENT '产品单价，单位：元',
                                         `contract_price` decimal(19, 2) NOT NULL COMMENT '合同价格，单位：元',
                                         `count` decimal(19, 2) NOT NULL COMMENT '数量',
                                         `total_price` decimal(19, 2) NOT NULL COMMENT '总计价格，单位：元',
                                         `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM合同产品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_customer
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer`;
CREATE TABLE `crm_customer`  (
                                 `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                 `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '客户名称',
                                 `follow_up_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '跟进状态',
                                 `contact_last_time` datetime(0) NULL DEFAULT NULL COMMENT '最后跟进时间',
                                 `contact_last_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '最后跟进内容',
                                 `contact_next_time` datetime(0) NULL DEFAULT NULL COMMENT '下次联系时间',
                                 `owner_user_id` bigint(0) NULL DEFAULT NULL COMMENT '负责人的用户编号，关联 AdminUserDO 的 id 字段',
                                 `owner_time` datetime(0) NULL DEFAULT NULL COMMENT '成为负责人的时间',
                                 `lock_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '锁定状态',
                                 `deal_status` tinyint(1) NOT NULL DEFAULT 0 COMMENT '成交状态',
                                 `mobile` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机',
                                 `telephone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '电话',
                                 `qq` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'QQ',
                                 `wechat` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'wechat',
                                 `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT 'email',
                                 `area_id` int(0) NULL DEFAULT NULL COMMENT '所在地，关联 Area 的 id 字段',
                                 `detail_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '详细地址',
                                 `industry_id` int(0) NULL DEFAULT NULL COMMENT '所属行业，对应字典 CRM_CUSTOMER_INDUSTRY',
                                 `level` int(0) NULL DEFAULT NULL COMMENT '客户等级，对应字典 CRM_CUSTOMER_LEVEL',
                                 `source` int(0) NULL DEFAULT NULL COMMENT '客户来源，对应字典 CRM_CUSTOMER_SOURCE',
                                 `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                                 `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                 `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                 `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                 `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                 `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                 `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                 `dept_id` bigint(0) NULL DEFAULT NULL COMMENT '部门ID',
                                 PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM客户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_customer_limit_config
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer_limit_config`;
CREATE TABLE `crm_customer_limit_config`  (
                                              `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                              `type` int(0) NOT NULL COMMENT '规则类型',
                                              `user_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '规则适用人群',
                                              `dept_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '规则适用部门',
                                              `max_count` int(0) NOT NULL COMMENT '数量上限',
                                              `deal_count_enabled` tinyint(1) NOT NULL COMMENT '成交客户是否占有拥有客户数，当且仅当 type 为 1 时使用',
                                              `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                              `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                              `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                              `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                              `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                              `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                              PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM客户限制配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_customer_pool_config
-- ----------------------------
DROP TABLE IF EXISTS `crm_customer_pool_config`;
CREATE TABLE `crm_customer_pool_config`  (
                                             `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                             `enabled` tinyint(1) NOT NULL COMMENT '是否启用客户公海',
                                             `contact_expire_days` int(0) NOT NULL COMMENT '未跟进放入公海天数',
                                             `deal_expire_days` int(0) NOT NULL COMMENT '未成交放入公海天数',
                                             `notify_enabled` tinyint(1) NULL DEFAULT NULL COMMENT '是否开启提前提醒',
                                             `notify_days` int(0) NULL DEFAULT NULL COMMENT '提前提醒天数',
                                             `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                             `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                             `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                             `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                             `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                             `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                             PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM客户公海配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_follow_up_record
-- ----------------------------
DROP TABLE IF EXISTS `crm_follow_up_record`;
CREATE TABLE `crm_follow_up_record`  (
                                         `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                         `biz_type` int(0) NOT NULL COMMENT '数据类型',
                                         `biz_id` bigint(0) NOT NULL COMMENT '数据编号',
                                         `type` int(0) NOT NULL COMMENT '跟进类型',
                                         `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '跟进内容',
                                         `next_time` datetime(0) NOT NULL COMMENT '下次联系时间',
                                         `pic_urls` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '图片',
                                         `file_urls` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '附件',
                                         `business_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '关联的商机编号数组',
                                         `contact_ids` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '关联的联系人编号数组',
                                         `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM跟进记录表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_permission
-- ----------------------------
DROP TABLE IF EXISTS `crm_permission`;
CREATE TABLE `crm_permission`  (
                                   `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
                                   `biz_type` int(0) NOT NULL COMMENT '数据类型',
                                   `biz_id` bigint(0) NOT NULL COMMENT '数据编号',
                                   `user_id` bigint(0) NOT NULL COMMENT '用户编号',
                                   `level` int(0) NOT NULL COMMENT '权限级别',
                                   `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                   `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                   `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 40 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM权限表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_product
-- ----------------------------
DROP TABLE IF EXISTS `crm_product`;
CREATE TABLE `crm_product`  (
                                `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '产品名称',
                                `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '产品编码',
                                `unit` int(0) NOT NULL COMMENT '单位，字典 CRM_PRODUCT_UNIT',
                                `price` decimal(19, 2) NOT NULL COMMENT '价格，单位：元',
                                `status` int(0) NOT NULL COMMENT '状态',
                                `category_id` bigint(0) NOT NULL COMMENT '产品分类 ID',
                                `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '产品描述',
                                `owner_user_id` bigint(0) NOT NULL COMMENT '负责人的用户编号',
                                `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM产品表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_product_category
-- ----------------------------
DROP TABLE IF EXISTS `crm_product_category`;
CREATE TABLE `crm_product_category`  (
                                         `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '分类编号',
                                         `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
                                         `parent_id` bigint(0) NOT NULL COMMENT '父级编号',
                                         `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM产品分类表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_receivable
-- ----------------------------
DROP TABLE IF EXISTS `crm_receivable`;
CREATE TABLE `crm_receivable`  (
                                   `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT 'ID',
                                   `no` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '回款编号',
                                   `plan_id` bigint(0) NULL DEFAULT NULL COMMENT '回款计划编号',
                                   `customer_id` bigint(0) NOT NULL COMMENT '客户编号',
                                   `contract_id` bigint(0) NOT NULL COMMENT '合同编号',
                                   `owner_user_id` bigint(0) NOT NULL COMMENT '负责人编号',
                                   `return_time` datetime(0) NOT NULL COMMENT '回款日期',
                                   `return_type` int(0) NULL DEFAULT NULL COMMENT '回款方式',
                                   `price` decimal(19, 2) NULL DEFAULT NULL COMMENT '计划回款金额，单位：元',
                                   `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                                   `process_instance_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '工作流编号',
                                   `audit_status` int(0) NOT NULL COMMENT '审批状态',
                                   `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                   `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                   `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM回款表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for crm_receivable_plan
-- ----------------------------
DROP TABLE IF EXISTS `crm_receivable_plan`;
CREATE TABLE `crm_receivable_plan`  (
                                        `id` bigint(0) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                        `period` int(0) NOT NULL COMMENT '期数',
                                        `customer_id` bigint(0) NOT NULL COMMENT '客户编号',
                                        `contract_id` bigint(0) NOT NULL COMMENT '合同编号',
                                        `owner_user_id` bigint(0) NOT NULL COMMENT '负责人编号',
                                        `return_time` datetime(0) NOT NULL COMMENT '计划回款日期',
                                        `return_type` int(0) NULL DEFAULT NULL COMMENT '计划回款类型',
                                        `price` decimal(19, 2) NOT NULL COMMENT '计划回款金额，单位：元',
                                        `receivable_id` bigint(0) NULL DEFAULT NULL COMMENT '回款编号',
                                        `remind_days` int(0) NULL DEFAULT NULL COMMENT '提前几天提醒',
                                        `remind_time` datetime(0) NULL DEFAULT NULL COMMENT '提醒日期',
                                        `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '备注',
                                        `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                        `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '更新者',
                                        `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint(0) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = 'CRM回款计划表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
