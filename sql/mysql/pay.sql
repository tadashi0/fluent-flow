DROP TABLE IF EXISTS `pay_app`;
CREATE TABLE `pay_app`  (
                            `id` bigint NOT NULL AUTO_INCREMENT COMMENT '应用编号',
                            `app_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用标识',
                            `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '应用名',
                            `status` tinyint NOT NULL COMMENT '开启状态',
                            `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
                            `order_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付结果的回调地址',
                            `refund_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '退款结果的回调地址',
                            `transfer_notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '转账结果的回调地址',
                            `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                            `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                            `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                            `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                            `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                            `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                            PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付应用信息';

DROP TABLE IF EXISTS `pay_channel`;
CREATE TABLE `pay_channel`  (
                                `id` bigint NOT NULL AUTO_INCREMENT COMMENT '渠道编号',
                                `code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道编码',
                                `status` tinyint NOT NULL COMMENT '开启状态',
                                `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '备注',
                                `fee_rate` double NOT NULL DEFAULT 0 COMMENT '渠道费率，单位：百分比',
                                `app_id` bigint NOT NULL COMMENT '应用编号',
                                `config` varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付渠道配置',
                                `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付渠道';

DROP TABLE IF EXISTS `pay_demo_order`;
CREATE TABLE `pay_demo_order`  (
                                   `id` bigint NOT NULL AUTO_INCREMENT COMMENT '订单编号',
                                   `user_id` bigint UNSIGNED NOT NULL COMMENT '用户编号',
                                   `spu_id` bigint NOT NULL COMMENT '商品编号',
                                   `spu_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '商品名字',
                                   `price` int NOT NULL COMMENT '价格，单位：分',
                                   `pay_status` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否已支付：[0:未支付 1:已经支付过]',
                                   `pay_order_id` bigint NULL DEFAULT NULL COMMENT '支付订单编号',
                                   `pay_channel_code` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT NULL COMMENT '支付成功的支付渠道',
                                   `pay_time` datetime NULL DEFAULT NULL COMMENT '订单支付时间',
                                   `pay_refund_id` bigint NULL DEFAULT NULL COMMENT '退款订单编号',
                                   `refund_price` int NOT NULL DEFAULT 0 COMMENT '退款金额，单位：分',
                                   `refund_time` datetime NULL DEFAULT NULL COMMENT '退款时间',
                                   `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NULL DEFAULT '' COMMENT '更新者',
                                   `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_bin COMMENT = '示例订单\n';

DROP TABLE IF EXISTS `pay_notify_log`;
CREATE TABLE `pay_notify_log`  (
                                   `id` bigint NOT NULL AUTO_INCREMENT COMMENT '日志编号',
                                   `task_id` bigint NOT NULL COMMENT '通知任务编号',
                                   `notify_times` tinyint NOT NULL COMMENT '第几次被通知',
                                   `response` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '请求参数',
                                   `status` tinyint NOT NULL COMMENT '通知状态',
                                   `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                   `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                   `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                   `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                   `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                   `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                   PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付通知 App 的日志';


DROP TABLE IF EXISTS `pay_notify_task`;
CREATE TABLE `pay_notify_task`  (
                                    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '任务编号',
                                    `app_id` bigint NOT NULL COMMENT '应用编号',
                                    `type` tinyint NOT NULL COMMENT '通知类型',
                                    `data_id` bigint NOT NULL COMMENT '数据编号',
                                    `merchant_order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商户订单编号',
                                    `merchant_transfer_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商户转账单编号',
                                    `status` tinyint NOT NULL COMMENT '通知状态',
                                    `next_notify_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下一次通知时间',
                                    `last_execute_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最后一次执行时间',
                                    `notify_times` tinyint NOT NULL COMMENT '当前通知次数',
                                    `max_notify_times` tinyint NOT NULL COMMENT '最大可通知次数',
                                    `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '异步通知地址',
                                    `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                    `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                    `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                    `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                    `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                    `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB  CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '商户支付、退款等的通知';

DROP TABLE IF EXISTS `pay_order`;
CREATE TABLE `pay_order`  (
                              `id` bigint NOT NULL AUTO_INCREMENT COMMENT '支付订单编号',
                              `app_id` bigint NOT NULL COMMENT '应用编号',
                              `channel_id` bigint NULL DEFAULT NULL COMMENT '渠道编号',
                              `channel_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道编码',
                              `merchant_order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商户订单编号',
                              `subject` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品标题',
                              `body` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商品描述',
                              `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '异步通知地址',
                              `price` int NOT NULL COMMENT '价格，单位：分',
                              `channel_fee_rate` double NULL DEFAULT 0 COMMENT '渠道手续费，单位：百分比',
                              `channel_fee_price` int NULL DEFAULT 0 COMMENT '渠道手续金额，单位：分',
                              `status` tinyint NOT NULL COMMENT '支付状态',
                              `user_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户 IP',
                              `expire_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订单失效时间',
                              `success_time` datetime NULL DEFAULT CURRENT_TIMESTAMP COMMENT '订单支付成功时间',
                              `extension_id` bigint NULL DEFAULT NULL COMMENT '支付成功的订单拓展单编号',
                              `no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NULL COMMENT '支付成功的外部订单号',
                              `refund_price` int NOT NULL COMMENT '退款总金额，单位：分',
                              `channel_user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道用户编号',
                              `channel_order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '渠道订单号',
                              `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                              `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                              `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                              `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                              `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                              PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付订单';

DROP TABLE IF EXISTS `pay_order_extension`;
CREATE TABLE `pay_order_extension`  (
                                        `id` bigint NOT NULL AUTO_INCREMENT COMMENT '支付订单编号',
                                        `no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '支付订单号',
                                        `order_id` bigint NOT NULL COMMENT '支付订单编号',
                                        `channel_id` bigint NOT NULL COMMENT '渠道编号',
                                        `channel_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道编码',
                                        `user_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户 IP',
                                        `status` tinyint NOT NULL COMMENT '支付状态',
                                        `channel_extras` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付渠道的额外参数',
                                        `channel_error_code` varchar(256) DEFAULT NULL COMMENT '调用渠道的错误码',
                                        `channel_error_msg` varchar(256) DEFAULT NULL COMMENT ' 调用渠道报错时，错误信息',
                                        `channel_notify_data` varchar(4096)  DEFAULT NULL COMMENT '支付渠道异步通知的内容',
                                        `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                        `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                        `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                        `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                        `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                        `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                        PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 383 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '支付订单\n';

DROP TABLE IF EXISTS `pay_refund`;
CREATE TABLE `pay_refund`  (
                               `id` bigint NOT NULL AUTO_INCREMENT COMMENT '支付退款编号',
                               `app_id` bigint NOT NULL COMMENT '应用编号',
                               `channel_id` bigint NOT NULL COMMENT '渠道编号',
                               `channel_code` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '渠道编码',
                               `order_id` bigint NOT NULL COMMENT '支付订单编号 pay_order 表id',
                               `order_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '交易订单号 pay_extension 表no 字段',
                               `merchant_order_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商户订单编号（商户系统生成）',
                               `merchant_refund_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '商户退款订单号（商户系统生成）',
                               `notify_url` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '异步通知商户地址',
                               `status` tinyint NOT NULL COMMENT '退款状态',
                               `pay_price` int NOT NULL COMMENT '支付金额,单位分',
                               `refund_price` bigint NOT NULL COMMENT '退款金额,单位分',
                               `reason` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '退款原因',
                               `user_ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '用户 IP',
                               `channel_order_no` varchar(64)  COMMENT '渠道订单号，pay_order 中的channel_order_no 对应',
                               `channel_refund_no` varchar(64) DEFAULT  NULL COMMENT '渠道退款单号，渠道返回',
                               `channel_error_code` varchar(128) DEFAULT NULL COMMENT '渠道调用报错时，错误码',
                               `channel_error_msg` varchar(256)  DEFAULT NULL COMMENT '渠道调用报错时，错误信息',
                               `success_time` datetime NULL DEFAULT NULL COMMENT '退款成功时间',
                               `channel_notify_time` datetime NULL DEFAULT NULL COMMENT '退款通知时间',
                               `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                               `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                               `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                               `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                               `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                               `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                               PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '退款订单';

DROP TABLE IF EXISTS `pay_transfer`;
CREATE TABLE `pay_transfer` (
                                `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '编号',
                                `no` varchar(255) DEFAULT NULL COMMENT '转账单号',
                                `app_id` bigint(20) DEFAULT NULL COMMENT '应用编号，关联 PayAppDO 的 id',
                                `channel_id` bigint(20) DEFAULT NULL COMMENT '转账渠道编号，关联 PayChannelDO 的 id',
                                `channel_code` varchar(255) DEFAULT NULL COMMENT '转账渠道编码，枚举 PayChannelEnum',
                                `merchant_transfer_id` varchar(255) DEFAULT NULL COMMENT '商户转账单编号',
                                `type` int(11) DEFAULT NULL COMMENT '类型，枚举 PayTransferTypeEnum',
                                `subject` varchar(255) DEFAULT NULL COMMENT '转账标题',
                                `price` int(11) DEFAULT NULL COMMENT '转账金额，单位：分',
                                `user_name` varchar(255) DEFAULT NULL COMMENT '收款人姓名',
                                `status` int(11) DEFAULT NULL COMMENT '转账状态，枚举 PayTransferStatusRespEnum',
                                `success_time` datetime DEFAULT NULL COMMENT '订单转账成功时间',
                                `alipay_logon_id` varchar(255) DEFAULT NULL COMMENT '支付宝登录号',
                                `openid` varchar(255) DEFAULT NULL COMMENT '微信 openId',
                                `notify_url` varchar(255) DEFAULT NULL COMMENT '异步通知地址',
                                `user_ip` varchar(255) DEFAULT NULL COMMENT '用户 IP',
                                `channel_extras` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '支付渠道的额外参数',
                                `channel_transfer_no` varchar(255) DEFAULT NULL COMMENT '渠道转账单号',
                                `channel_error_code` varchar(255) DEFAULT NULL COMMENT '调用渠道的错误码',
                                `channel_error_msg` varchar(255) DEFAULT NULL COMMENT '调用渠道的错误提示',
                                `channel_notify_data` varchar(255) DEFAULT NULL COMMENT '渠道的同步/异步通知的内容',
                                `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='转账单';


DROP TABLE IF EXISTS `pay_wallet`;
CREATE TABLE `pay_wallet` (
                              `id` bigint(20) NOT NULL AUTO_INCREMENT  COMMENT '编号',
                              `user_id` bigint(20) DEFAULT NULL COMMENT '用户 id',
                              `user_type` int(11) DEFAULT NULL COMMENT '用户类型',
                              `balance` int(11) DEFAULT NULL COMMENT '余额，单位分',
                              `freeze_price` int(11) DEFAULT NULL COMMENT '冻结金额，单位分',
                              `total_expense` int(11) DEFAULT NULL COMMENT '累计支出，单位分',
                              `total_recharge` int(11) DEFAULT NULL COMMENT '累计充值，单位分',
                              `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                              `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                              `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                              `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                              `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                              PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员钱包';

DROP TABLE IF EXISTS `pay_wallet_recharge`;
CREATE TABLE `pay_wallet_recharge` (
                                       `id` bigint(20) NOT NULL COMMENT '编号',
                                       `wallet_id` bigint(20) DEFAULT NULL COMMENT '钱包编号',
                                       `total_price` int(11) DEFAULT NULL COMMENT '用户实际到账余额',
                                       `pay_price` int(11) DEFAULT NULL COMMENT '实际支付金额',
                                       `bonus_price` int(11) DEFAULT NULL COMMENT '钱包赠送金额',
                                       `package_id` bigint(20) DEFAULT NULL COMMENT '充值套餐编号',
                                       `pay_status` tinyint(1) DEFAULT NULL COMMENT '是否已支付',
                                       `pay_order_id` bigint(20) DEFAULT NULL COMMENT '支付订单编号',
                                       `pay_channel_code` varchar(255) DEFAULT NULL COMMENT '支付成功的支付渠道',
                                       `pay_time` datetime DEFAULT NULL COMMENT '订单支付时间',
                                       `pay_refund_id` bigint(20) DEFAULT NULL COMMENT '支付退款单编号',
                                       `refund_total_price` int(11) DEFAULT NULL COMMENT '退款金额，包含赠送金额',
                                       `refund_pay_price` int(11) DEFAULT NULL COMMENT '退款支付金额',
                                       `refund_bonus_price` int(11) DEFAULT NULL COMMENT '退款钱包赠送金额',
                                       `refund_time` datetime DEFAULT NULL COMMENT '退款时间',
                                       `refund_status` int(11) DEFAULT NULL COMMENT '退款状态',
                                       `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                       `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                       `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                       `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                       `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                       `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                       PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员钱包充值';

DROP TABLE IF EXISTS `pay_wallet_recharge_package`;
CREATE TABLE `pay_wallet_recharge_package` (
                                               `id` bigint(20) NOT NULL COMMENT '编号',
                                               `name` varchar(255) DEFAULT NULL COMMENT '套餐名',
                                               `pay_price` int(11) DEFAULT NULL COMMENT '支付金额',
                                               `bonus_price` int(11) DEFAULT NULL COMMENT '赠送金额',
                                               `status` int(11) DEFAULT NULL COMMENT '状态',
                                               `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                               `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                               `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                               `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                               `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                               `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                               PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员钱包充值套餐';

DROP TABLE IF EXISTS `pay_wallet_transaction`;
CREATE TABLE `pay_wallet_transaction` (
                                          `id` bigint(20) NOT NULL COMMENT '编号',
                                          `no` varchar(255) DEFAULT NULL COMMENT '流水号',
                                          `wallet_id` bigint(20) DEFAULT NULL COMMENT '钱包编号',
                                          `biz_type` int(11) DEFAULT NULL COMMENT '关联业务分类',
                                          `biz_id` varchar(255) DEFAULT NULL COMMENT '关联业务编号',
                                          `title` varchar(255) DEFAULT NULL COMMENT '流水说明',
                                          `price` int(11) DEFAULT NULL COMMENT '交易金额，单位分，正值表示余额增加，负值表示余额减少',
                                          `balance` int(11) DEFAULT NULL COMMENT '交易后余额，单位分',
                                          `creator` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '创建者',
                                          `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                          `updater` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT '' COMMENT '更新者',
                                          `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                          `deleted` bit(1) NOT NULL DEFAULT b'0' COMMENT '是否删除',
                                          `tenant_id` bigint NOT NULL DEFAULT 0 COMMENT '租户编号',
                                          PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会员钱包流水';
