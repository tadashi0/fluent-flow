DROP TABLE IF EXISTS `erp_customer`;
CREATE TABLE `erp_customer` (
                                `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '客户编号',
                                `name` VARCHAR(255) NOT NULL COMMENT '客户名称',
                                `contact` VARCHAR(255) NOT NULL COMMENT '联系人',
                                `mobile` VARCHAR(255) NOT NULL COMMENT '手机号码',
                                `telephone` VARCHAR(255) NOT NULL COMMENT '联系电话',
                                `email` VARCHAR(255) NOT NULL COMMENT '电子邮箱',
                                `fax` VARCHAR(255) NOT NULL COMMENT '传真',
                                `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                `status` INT(11) NOT NULL COMMENT '开启状态',
                                `sort` INT(11) NOT NULL COMMENT '排序',
                                `tax_no` VARCHAR(255) NOT NULL COMMENT '纳税人识别号',
                                `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率',
                                `bank_name` VARCHAR(255) NOT NULL COMMENT '开户行',
                                `bank_account` VARCHAR(255) NOT NULL COMMENT '开户账号',
                                `bank_address` VARCHAR(255) NOT NULL COMMENT '开户地址',
                                `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64)  COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP客户表';


DROP TABLE IF EXISTS `erp_sale_order`;
CREATE TABLE `erp_sale_order` (
                                  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                  `no` VARCHAR(255) NOT NULL COMMENT '销售订单号',
                                  `status` INT(11) NOT NULL COMMENT '销售状态',
                                  `customer_id` BIGINT(20) NOT NULL COMMENT '客户编号段',
                                  `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                  `sale_user_id` BIGINT(20) NOT NULL COMMENT '销售员编号',
                                  `order_time` DATETIME NOT NULL COMMENT '下单时间',
                                  `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                  `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                  `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                  `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                  `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                  `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                  `deposit_price` DECIMAL(10,2) NOT NULL COMMENT '定金金额，单位：元',
                                  `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                  `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                  `out_count` DECIMAL(10,2) NOT NULL COMMENT '销售出库数量',
                                  `return_count` DECIMAL(10,2) NOT NULL COMMENT '销售退货数量',
                                  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                  `updater` varchar(64)  COMMENT '更新者',
                                  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                  `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP销售订单表';

DROP TABLE IF EXISTS `erp_sale_order_items`;
CREATE TABLE `erp_sale_order_items` (
                                        `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                        `order_id` BIGINT(20) NOT NULL COMMENT '销售订单编号',
                                        `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                        `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                        `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                        `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                        `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                        `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                        `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                        `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                        `out_count` DECIMAL(10,2) NOT NULL COMMENT '销售出库数量',
                                        `return_count` DECIMAL(10,2) NOT NULL COMMENT '销售退货数量',
                                        `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                        `updater` varchar(64)  COMMENT '更新者',
                                        `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP销售订单项表';

DROP TABLE IF EXISTS `erp_sale_out`;
CREATE TABLE `erp_sale_out` (
                                `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                `no` VARCHAR(255) NOT NULL COMMENT '销售出库单号',
                                `status` INT(11) NOT NULL COMMENT '出库状态s',
                                `customer_id` BIGINT(20) NOT NULL COMMENT '客户编号段',
                                `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                `sale_user_id` BIGINT(20) NOT NULL COMMENT '销售员编号',
                                `out_time` DATETIME NOT NULL COMMENT '出库时间',
                                `order_id` BIGINT(20) NOT NULL COMMENT '销售订单编号',
                                `order_no` VARCHAR(255) NOT NULL COMMENT '销售订单号',
                                `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                `receipt_price` DECIMAL(10,2) NOT NULL COMMENT '已收款金额，单位：元',
                                `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                `other_price` DECIMAL(10,2) NOT NULL COMMENT '其它金额，单位：元',
                                `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64)  COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP销售出库表';

DROP TABLE IF EXISTS `erp_sale_out_items`;
CREATE TABLE `erp_sale_out_items` (
                                      `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                      `out_id` BIGINT(20) NOT NULL COMMENT '销售出库编号',
                                      `order_item_id` BIGINT(20) NOT NULL COMMENT '销售订单项编号',
                                      `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                      `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                      `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                      `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                      `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                      `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                      `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                      `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                      `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                      `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                      `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                      `updater` varchar(64)  COMMENT '更新者',
                                      `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                      `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                      `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='EPR销售出库项表';


DROP TABLE IF EXISTS `erp_sale_return`;
CREATE TABLE `erp_sale_return` (
                                   `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                   `no` VARCHAR(255) NOT NULL COMMENT '销售退货单号',
                                   `status` INT(11) NOT NULL COMMENT '退货状态',
                                   `customer_id` BIGINT(20) NOT NULL COMMENT '客户编号',
                                   `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                   `sale_user_id` BIGINT(20) NOT NULL COMMENT '销售员编号',
                                   `return_time` DATETIME NOT NULL COMMENT '退货时间',
                                   `order_id` BIGINT(20) NOT NULL COMMENT '销售订单编号',
                                   `order_no` VARCHAR(255) NOT NULL COMMENT '销售订单号',
                                   `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                   `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                   `refund_price` DECIMAL(10,2) NOT NULL COMMENT '已退款金额，单位：元',
                                   `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                   `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                   `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                   `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                   `other_price` DECIMAL(10,2) NOT NULL COMMENT '其它金额，单位：元',
                                   `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                   `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                   `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                   `updater` varchar(64)  COMMENT '更新者',
                                   `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP销售退货表';

DROP TABLE IF EXISTS `erp_sale_return_items`;
CREATE TABLE `erp_sale_return_items` (
                                         `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                         `return_id` BIGINT(20) NOT NULL COMMENT '销售退货编号',
                                         `order_item_id` BIGINT(20) NOT NULL COMMENT '销售订单项编号，方便更新关联的销售订单项的退货数量',
                                         `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                         `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                         `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                         `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                         `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                         `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                         `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                         `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                         `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP销售退货项表';

DROP TABLE IF EXISTS `erp_stock_check`;
CREATE TABLE `erp_stock_check` (
                                   `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '盘点编号',
                                   `no` VARCHAR(255) NOT NULL COMMENT '盘点单号',
                                   `check_time` DATETIME NOT NULL COMMENT '盘点时间',
                                   `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                   `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                   `status` INT(11) NOT NULL COMMENT '状态',
                                   `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                   `file_url` VARCHAR(255) NOT NULL COMMENT '附件 URL',
                                   `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                   `updater` varchar(64)  COMMENT '更新者',
                                   `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP库存盘点表';

DROP TABLE IF EXISTS `erp_stock_check_item`;
CREATE TABLE `erp_stock_check_item` (
                                        `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '盘点项编号',
                                        `check_id` BIGINT(20) NOT NULL COMMENT '盘点编号',
                                        `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                        `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                        `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位编号',
                                        `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单价',
                                        `stock_count` DECIMAL(10,2) NOT NULL COMMENT '账面数量（当前库存）',
                                        `actual_count` DECIMAL(10,2) NOT NULL COMMENT '实际数量（实际库存）',
                                        `count` DECIMAL(10,2) NOT NULL COMMENT '盈亏数量，count = stockCount - actualCount',
                                        `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                        `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                        `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                        `updater` varchar(64)  COMMENT '更新者',
                                        `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='库存盘点项表';


DROP TABLE IF EXISTS `erp_stock`;
CREATE TABLE `erp_stock` (
                             `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                             `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                             `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                             `count` DECIMAL(10,2) NOT NULL COMMENT '库存数量',
                             `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                             `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                             `updater` varchar(64)  COMMENT '更新者',
                             `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                             `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                             `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                             PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP库存表';

DROP TABLE IF EXISTS `erp_stock_in`;
CREATE TABLE `erp_stock_in` (
                                `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '入库编号',
                                `no` VARCHAR(255) NOT NULL COMMENT '入库单号',
                                `supplier_id` BIGINT(20) NOT NULL COMMENT '供应商编号',
                                `in_time` DATETIME NOT NULL COMMENT '入库时间',
                                `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                `status` INT(11) NOT NULL COMMENT '状态',
                                `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                `file_url` VARCHAR(255) NOT NULL COMMENT '附件 URL',
                                `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64)  COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP入库表';


DROP TABLE IF EXISTS `erp_stock_in_item`;
CREATE TABLE `erp_stock_in_item` (
                                     `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
                                     `in_id` BIGINT(20) NOT NULL COMMENT '入库编号',
                                     `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                     `product_id` BIGINT(20) NOT NULL COMMENT '产品编号段',
                                     `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位编号',
                                     `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单价',
                                     `count` DECIMAL(10,2) NOT NULL COMMENT '产品数量',
                                     `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                     `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                     `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                     `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                     `updater` varchar(64)  COMMENT '更新者',
                                     `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                     `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                     `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                     PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP入库项表';


DROP TABLE IF EXISTS `erp_stock_move`;
CREATE TABLE `erp_stock_move` (
                                  `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '调拨编号',
                                  `no` VARCHAR(255) NOT NULL COMMENT '调拨单号',
                                  `move_time` DATETIME NOT NULL COMMENT '调拨时间',
                                  `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                  `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                  `status` INT(11) NOT NULL COMMENT '状态',
                                  `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                  `file_url` VARCHAR(255) NOT NULL COMMENT '附件 URL',
                                  `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                  `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                  `updater` varchar(64)  COMMENT '更新者',
                                  `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                  `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                  `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP调拨表';


DROP TABLE IF EXISTS `erp_stock_move_item`;
CREATE TABLE `erp_stock_move_item` (
                                       `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '调拨项编号',
                                       `move_id` BIGINT(20) NOT NULL COMMENT '调拨编号',
                                       `from_warehouse_id` BIGINT(20) NOT NULL COMMENT '调出仓库编号',
                                       `to_warehouse_id` BIGINT(20) NOT NULL COMMENT '调入仓库编号',
                                       `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                       `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位编号',
                                       `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单价',
                                       `count` DECIMAL(10,2) NOT NULL COMMENT '产品数量',
                                       `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                       `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                       `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                       `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                       `updater` varchar(64)  COMMENT '更新者',
                                       `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                       `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                       `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                       PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP调拨项表';

DROP TABLE IF EXISTS `erp_stock_out`;
CREATE TABLE `erp_stock_out` (
                                 `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '出库编号',
                                 `no` VARCHAR(255) NOT NULL COMMENT '出库单号',
                                 `customer_id` BIGINT(20) NOT NULL COMMENT '客户编号',
                                 `out_time` DATETIME NOT NULL COMMENT '出库时间',
                                 `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                 `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                 `status` INT(11) NOT NULL COMMENT '状态',
                                 `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                 `file_url` VARCHAR(255) NOT NULL COMMENT '附件 URL',
                                 `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                 `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                 `updater` varchar(64)  COMMENT '更新者',
                                 `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                 `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                 `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                 PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='出库表';


DROP TABLE IF EXISTS `erp_stock_out_item`;
CREATE TABLE `erp_stock_out_item` (
                                      `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '出库项编号',
                                      `out_id` BIGINT(20) NOT NULL COMMENT '出库编号',
                                      `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                      `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                      `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位编号',
                                      `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单价',
                                      `count` DECIMAL(10,2) NOT NULL COMMENT '产品数量',
                                      `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计金额，单位：元',
                                      `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                      `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                      `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                      `updater` varchar(64)  COMMENT '更新者',
                                      `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                      `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                      `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP出库项表';

DROP TABLE IF EXISTS `erp_stock_record`;
CREATE TABLE `erp_stock_record` (
                                    `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                    `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                    `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                    `count` DECIMAL(10,2) NOT NULL COMMENT '出入库数量，正数表示入库，负数表示出库',
                                    `total_count` DECIMAL(10,2) NOT NULL COMMENT '总库存量，出入库之后的当前库存量',
                                    `biz_type` INT(11) NOT NULL COMMENT '业务类型',
                                    `biz_id` BIGINT(20) NOT NULL COMMENT '业务编号',
                                    `biz_item_id` BIGINT(20) NOT NULL COMMENT '业务项编号',
                                    `biz_no` VARCHAR(255) NOT NULL COMMENT '业务单号',
                                    `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                    `updater` varchar(64)  COMMENT '更新者',
                                    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                    `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                    `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP库存记录表';

DROP TABLE IF EXISTS `erp_warehouse`;
CREATE TABLE `erp_warehouse` (
                                 `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '仓库编号',
                                 `name` VARCHAR(255) NOT NULL COMMENT '仓库名称',
                                 `address` VARCHAR(255) NOT NULL COMMENT '仓库地址',
                                 `sort` BIGINT(20) NOT NULL COMMENT '排序',
                                 `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                 `principal` VARCHAR(255) NOT NULL COMMENT '负责人',
                                 `warehouse_price` DECIMAL(10,2) NOT NULL COMMENT '仓储费，单位：元',
                                 `truckage_price` DECIMAL(10,2) NOT NULL COMMENT '搬运费，单位：元',
                                 `status` INT(11) NOT NULL COMMENT '开启状态',
                                 `default_status` TINYINT(1) NOT NULL COMMENT '是否默认',
                                 `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                 `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                 `updater` varchar(64)  COMMENT '更新者',
                                 `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                 `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                 `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                 PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP仓库表';
DROP TABLE IF EXISTS `erp_purchase_in`;
CREATE TABLE `erp_purchase_in` (
                                   `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                   `no` VARCHAR(255) NOT NULL COMMENT '采购入库单号',
                                   `status` INT(11) NOT NULL COMMENT '入库状态',
                                   `supplier_id` BIGINT(20) NOT NULL COMMENT '供应商编号',
                                   `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                   `in_time` DATETIME NOT NULL COMMENT '入库时间',
                                   `order_id` BIGINT(20) NOT NULL COMMENT '采购订单编号',
                                   `order_no` VARCHAR(255) NOT NULL COMMENT '采购订单号',
                                   `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                   `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                   `payment_price` DECIMAL(10,2) NOT NULL COMMENT '已支付金额，单位：元',
                                   `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                   `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                   `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                   `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                   `other_price` DECIMAL(10,2) NOT NULL COMMENT '其它金额，单位：元',
                                   `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                   `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                   `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                   `updater` varchar(64)  COMMENT '更新者',
                                   `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购入库表';


DROP TABLE IF EXISTS `erp_purchase_in_items`;
CREATE TABLE `erp_purchase_in_items` (
                                         `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                         `in_id` BIGINT(20) NOT NULL COMMENT '采购入库编号',
                                         `order_item_id` BIGINT(20) NOT NULL COMMENT '采购订单项编号',
                                         `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                         `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                         `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                         `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                         `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                         `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                         `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                         `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                         `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                         `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                         `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                         `updater` varchar(64)  COMMENT '更新者',
                                         `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                         `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                         `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                         PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购入库明细表';

DROP TABLE IF EXISTS `erp_purchase_order`;
CREATE TABLE `erp_purchase_order` (
                                      `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                      `no` VARCHAR(255) NOT NULL COMMENT '采购订单号',
                                      `status` INT(11) NOT NULL COMMENT '采购状态',
                                      `supplier_id` BIGINT(20) NOT NULL COMMENT '供应商编号',
                                      `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                      `order_time` DATETIME NOT NULL COMMENT '下单时间',
                                      `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                      `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                      `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                      `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                      `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                      `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                      `deposit_price` DECIMAL(10,2) NOT NULL COMMENT '定金金额，单位：元',
                                      `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                      `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                      `in_count` DECIMAL(10,2) NOT NULL COMMENT '采购入库数量',
                                      `return_count` DECIMAL(10,2) NOT NULL COMMENT '采购退货数量',
                                      `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                      `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                      `updater` varchar(64)  COMMENT '更新者',
                                      `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                      `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                      `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购订单表';

DROP TABLE IF EXISTS `erp_purchase_order_items`;
CREATE TABLE `erp_purchase_order_items` (
                                            `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                            `order_id` BIGINT(20) NOT NULL COMMENT '采购订单编号',
                                            `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                            `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                            `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                            `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                            `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                            `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                            `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                            `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                            `in_count` DECIMAL(10,2) NOT NULL COMMENT '采购入库数量',
                                            `return_count` DECIMAL(10,2) NOT NULL COMMENT '采购退货数量',
                                            `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                            `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                            `updater` varchar(64)  COMMENT '更新者',
                                            `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                            `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                            `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购订单明细表';

DROP TABLE IF EXISTS `erp_purchase_return`;
CREATE TABLE `erp_purchase_return` (
                                       `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                       `no` VARCHAR(255) NOT NULL COMMENT '采购退货单号',
                                       `status` INT(11) NOT NULL COMMENT '退货状态',
                                       `supplier_id` BIGINT(20) NOT NULL COMMENT '供应商编号',
                                       `account_id` BIGINT(20) NOT NULL COMMENT '结算账户编号',
                                       `return_time` DATETIME NOT NULL COMMENT '退货时间',
                                       `order_id` BIGINT(20) NOT NULL COMMENT '采购订单编号',
                                       `order_no` VARCHAR(255) NOT NULL COMMENT '采购订单号',
                                       `total_count` DECIMAL(10,2) NOT NULL COMMENT '合计数量',
                                       `total_price` DECIMAL(10,2) NOT NULL COMMENT '最终合计价格，单位：元',
                                       `refund_price` DECIMAL(10,2) NOT NULL COMMENT '已退款金额，单位：元',
                                       `total_product_price` DECIMAL(10,2) NOT NULL COMMENT '合计产品价格，单位：元',
                                       `total_tax_price` DECIMAL(10,2) NOT NULL COMMENT '合计税额，单位：元',
                                       `discount_percent` DECIMAL(10,2) NOT NULL COMMENT '优惠率，百分比',
                                       `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                       `other_price` DECIMAL(10,2) NOT NULL COMMENT '其他金额，单位：元',
                                       `file_url` VARCHAR(255) NOT NULL COMMENT '附件地址',
                                       `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                       `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                       `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                       `updater` varchar(64)  COMMENT '更新者',
                                       `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                       `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                       `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                       PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购退货表';


DROP TABLE IF EXISTS `erp_purchase_return_items`;
CREATE TABLE `erp_purchase_return_items` (
                                             `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                             `return_id` BIGINT(20) NOT NULL COMMENT '采购退货编号',
                                             `order_item_id` BIGINT(20) NOT NULL COMMENT '采购订单项编号',
                                             `warehouse_id` BIGINT(20) NOT NULL COMMENT '仓库编号',
                                             `product_id` BIGINT(20) NOT NULL COMMENT '产品编号',
                                             `product_unit_id` BIGINT(20) NOT NULL COMMENT '产品单位单位',
                                             `product_price` DECIMAL(10,2) NOT NULL COMMENT '产品单位单价，单位：元',
                                             `count` DECIMAL(10,2) NOT NULL COMMENT '数量',
                                             `total_price` DECIMAL(10,2) NOT NULL COMMENT '总价，单位：元',
                                             `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率，百分比',
                                             `tax_price` DECIMAL(10,2) NOT NULL COMMENT '税额，单位：元',
                                             `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                             `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                             `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                             `updater` varchar(64)  COMMENT '更新者',
                                             `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                             `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                             `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                             PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP采购退货明细表';

DROP TABLE IF EXISTS `erp_supplier`;
CREATE TABLE `erp_supplier` (
                                `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '供应商编号',
                                `name` VARCHAR(255) NOT NULL COMMENT '供应商名称',
                                `contact` VARCHAR(255) NOT NULL COMMENT '联系人',
                                `mobile` VARCHAR(20) NOT NULL COMMENT '手机号码',
                                `telephone` VARCHAR(20) NOT NULL COMMENT '联系电话',
                                `email` VARCHAR(255) NOT NULL COMMENT '电子邮箱',
                                `fax` VARCHAR(20) NOT NULL COMMENT '传真',
                                `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                `status` INT(11) NOT NULL COMMENT '开启状态',
                                `sort` INT(11) NOT NULL COMMENT '排序',
                                `tax_no` VARCHAR(50) NOT NULL COMMENT '纳税人识别号',
                                `tax_percent` DECIMAL(10,2) NOT NULL COMMENT '税率',
                                `bank_name` VARCHAR(255) NOT NULL COMMENT '开户行',
                                `bank_account` VARCHAR(255) NOT NULL COMMENT '开户账号',
                                `bank_address` VARCHAR(255) NOT NULL COMMENT '开户地址',
                                `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                `updater` varchar(64)  COMMENT '更新者',
                                `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP供应商表';
DROP TABLE IF EXISTS `erp_account`;
CREATE TABLE `erp_account` (
                               `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '结算账户编号',
                               `name` VARCHAR(255) NOT NULL COMMENT '账户名称',
                               `no` VARCHAR(255) NOT NULL COMMENT '账户编码',
                               `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                               `status` INT(11) NOT NULL COMMENT '开启状态，枚举 CommonStatusEnum',
                               `sort` INT(11) NOT NULL COMMENT '排序',
                               `default_status` TINYINT(1) NOT NULL COMMENT '是否默认',
                               `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                               `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                               `updater` varchar(64)  COMMENT '更新者',
                               `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                               `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                               `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                               PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP结算账户表';

DROP TABLE IF EXISTS `erp_finance_payment`;
CREATE TABLE `erp_finance_payment` (
                                       `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                       `no` VARCHAR(255) NOT NULL COMMENT '付款单号',
                                       `status` INT(11) NOT NULL COMMENT '付款状态，枚举 ErpAuditStatus',
                                       `payment_time` DATETIME NOT NULL COMMENT '付款时间',
                                       `finance_user_id` BIGINT(20) NOT NULL COMMENT '财务人员编号，关联 AdminUserDO 的 id 字段',
                                       `supplier_id` BIGINT(20) NOT NULL COMMENT '供应商编号，关联 ErpSupplierDO 的 id 字段',
                                       `account_id` BIGINT(20) NOT NULL COMMENT '付款账户编号，关联 ErpAccountDO 的 id 字段',
                                       `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计价格，单位：元',
                                       `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                       `payment_price` DECIMAL(10,2) NOT NULL COMMENT '实付金额，单位：分',
                                       `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                       `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                       `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                       `updater` varchar(64)  COMMENT '更新者',
                                       `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                       `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                       `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                       PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP财务付款表';

DROP TABLE IF EXISTS `erp_finance_payment_item`;
CREATE TABLE `erp_finance_payment_item` (
                                            `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
                                            `payment_id` BIGINT(20) NOT NULL COMMENT '付款单编号，关联 ErpFinancePaymentDO 的 id 字段',
                                            `biz_type` INT(11) NOT NULL COMMENT '业务类型，枚举 ErpBizTypeEnum 的采购入库、退货',
                                            `biz_id` BIGINT(20) NOT NULL COMMENT '业务编号，例如说：ErpPurchaseInDO 的 id 字段',
                                            `biz_no` VARCHAR(255) NOT NULL COMMENT '业务单号，例如说：ErpPurchaseInDO 的 no 字段',
                                            `total_price` DECIMAL(10,2) NOT NULL COMMENT '应付金额，单位：分',
                                            `paid_price` DECIMAL(10,2) NOT NULL COMMENT '已付金额，单位：分',
                                            `payment_price` DECIMAL(10,2) NOT NULL COMMENT '本次付款，单位：分',
                                            `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                            `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                            `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                            `updater` varchar(64)  COMMENT '更新者',
                                            `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                            `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                            `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP财务付款项表';

DROP TABLE IF EXISTS `erp_finance_receipt`;
CREATE TABLE `erp_finance_receipt` (
                                       `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                       `no` VARCHAR(255) NOT NULL COMMENT '收款单号',
                                       `status` INT(11) NOT NULL COMMENT '收款状态，枚举 ErpAuditStatus',
                                       `receipt_time` DATETIME NOT NULL COMMENT '收款时间',
                                       `finance_user_id` BIGINT(20) NOT NULL COMMENT '财务人员编号，关联 AdminUserDO 的 id 字段',
                                       `customer_id` BIGINT(20) NOT NULL COMMENT '客户编号，关联 ErpCustomerDO 的 id 字段',
                                       `account_id` BIGINT(20) NOT NULL COMMENT '收款账户编号，关联 ErpAccountDO 的 id 字段',
                                       `total_price` DECIMAL(10,2) NOT NULL COMMENT '合计价格，单位：元',
                                       `discount_price` DECIMAL(10,2) NOT NULL COMMENT '优惠金额，单位：元',
                                       `receipt_price` DECIMAL(10,2) NOT NULL COMMENT '实付金额，单位：分',
                                       `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                       `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                       `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                       `updater` varchar(64)  COMMENT '更新者',
                                       `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                       `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                       `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                       PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP财务收款表';

DROP TABLE IF EXISTS `erp_finance_receipt_item`;
CREATE TABLE `erp_finance_receipt_item` (
                                            `id` BIGINT(20) NOT NULL AUTO_INCREMENT COMMENT '入库项编号',
                                            `receipt_id` BIGINT(20) NOT NULL COMMENT '收款单编号，关联 ErpFinanceReceiptDO 的 id 字段',
                                            `biz_type` INT(11) NOT NULL COMMENT '业务类型，枚举 ErpBizTypeEnum 的销售出库、退货',
                                            `biz_id` BIGINT(20) NOT NULL COMMENT '业务编号，例如说：ErpSaleOutDO 的 id 字段',
                                            `biz_no` VARCHAR(255) NOT NULL COMMENT '业务单号，例如说：ErpSaleOutDO 的 no 字段',
                                            `total_price` DECIMAL(10,2) NOT NULL COMMENT '应收金额，单位：分',
                                            `receipted_price` DECIMAL(10,2) NOT NULL COMMENT '已收金额，单位：分',
                                            `receipt_price` DECIMAL(10,2) NOT NULL COMMENT '本次收款，单位：分',
                                            `remark` VARCHAR(255) NOT NULL COMMENT '备注',
                                            `creator` varchar(64) DEFAULT '' COMMENT '创建者',
                                            `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
                                            `updater` varchar(64)  COMMENT '更新者',
                                            `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
                                            `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                            `tenant_id` bigint(20) NOT NULL DEFAULT 0 COMMENT '租户编号',
                                            PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='ERP财务收款项表';
