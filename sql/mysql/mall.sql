DROP TABLE IF EXISTS `product_brand`;
CREATE TABLE `product_brand`
(
    `id`          bigint(20)                                                     NOT NULL AUTO_INCREMENT COMMENT '品牌编号',
    `name`        varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '品牌名称',
    `pic_url`     varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '品牌图片',
    `sort`        int(11)                                                        NULL     DEFAULT 0 COMMENT '品牌排序',
    `description` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '品牌描述',
    `status`      tinyint(4)                                                     NOT NULL COMMENT '状态',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NULL     DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NULL     DEFAULT '' COMMENT '更新者',
    `update_time` datetime(0)                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                         NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                     NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '商品品牌';


DROP TABLE IF EXISTS `product_category`;
CREATE TABLE `product_category`
(
    `id`          bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '分类编号',
    `parent_id`   bigint(20)                                                    NOT NULL COMMENT '父分类编号',
    `name`        varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称',
    `pic_url`     varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类图',
    `sort`        int(11)                                                       NULL     DEFAULT 0 COMMENT '分类排序',
    `status`      tinyint(4)                                                    NOT NULL COMMENT '开启状态',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NULL     DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci  NULL     DEFAULT '' COMMENT '更新者',
    `update_time` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                        NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                    NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '商品分类';


DROP TABLE IF EXISTS `product_comment`;
CREATE TABLE `product_comment`
(
    `id`                 bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '评论编号，主键自增',
    `user_id`            bigint(20)                                                   NULL     DEFAULT NULL COMMENT '评价人的用户编号关联 MemberUserDO 的 id 编号',
    `user_nickname`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin       NULL     DEFAULT NULL COMMENT '评价人名称',
    `user_avatar`        varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      NULL     DEFAULT NULL COMMENT '评价人头像',
    `anonymous`          bit(1)                                                       NULL     DEFAULT NULL COMMENT '是否匿名',
    `order_id`           bigint(20)                                                   NULL     DEFAULT NULL COMMENT '交易订单编号关联 TradeOrderDO 的 id 编号',
    `order_item_id`      bigint(20)                                                   NULL     DEFAULT NULL COMMENT '交易订单项编号关联 TradeOrderItemDO 的 id 编号',
    `spu_id`             bigint(20)                                                   NULL     DEFAULT NULL COMMENT '商品 SPU 编号关联 ProductSpuDO 的 id',
    `spu_name`           varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin       NULL     DEFAULT NULL COMMENT '商品 SPU 名称',
    `sku_id`             bigint(20)                                                   NULL     DEFAULT NULL COMMENT '商品 SKU 编号关联 ProductSkuDO 的 id 编号',
    `sku_pic_url`        varchar(256)                                                          DEFAULT NULL COMMENT 'sku图片地址',
    `sku_properties`     varchar(512)                                                          DEFAULT NULL COMMENT 'sku属性数组，JSON 格式',
    `visible`            bit(1)                                                       NULL     DEFAULT NULL COMMENT '是否可见true:显示false:隐藏',
    `scores`             tinyint(4)                                                   NULL     DEFAULT NULL COMMENT '评分星级1-5分',
    `description_scores` tinyint(4)                                                   NULL     DEFAULT NULL COMMENT '描述星级1-5 星',
    `benefit_scores`     tinyint(4)                                                   NULL     DEFAULT NULL COMMENT '服务星级1-5 星',
    `content`            varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      NULL     DEFAULT NULL COMMENT '评论内容',
    `pic_urls`           varchar(4096) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      NULL     DEFAULT NULL COMMENT '评论图片地址数组',
    `reply_status`       bit(1)                                                       NULL     DEFAULT NULL COMMENT '商家是否回复',
    `reply_user_id`      bigint(20)                                                   NULL     DEFAULT NULL COMMENT '回复管理员编号关联 AdminUserDO 的 id 编号',
    `reply_content`      varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin      NULL     DEFAULT NULL COMMENT '商家回复内容',
    `reply_time`         datetime(0)                                                  NULL     DEFAULT NULL COMMENT '商家回复时间',
    `creator`            varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time`        datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`            varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time`        datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`            bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`          bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '商品评论';


DROP TABLE IF EXISTS `product_property`;
CREATE TABLE `product_property`
(
    `id`          bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT NULL COMMENT '规格名称',
    `status`      tinyint(4)                                                   NULL     DEFAULT NULL COMMENT '状态： 0 开启 ，1 禁用',
    `remark`      varchar(255)                                                          DEFAULT NULL COMMENT '备注',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '规格名称';


DROP TABLE IF EXISTS `product_property_value`;
CREATE TABLE `product_property_value`
(
    `id`          bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '主键',
    `property_id` bigint(20)                                                   NULL     DEFAULT NULL COMMENT '规格键id',
    `name`        varchar(128)                                                          DEFAULT NULL COMMENT '规格值名字',
    `remark`      varchar(255)                                                          DEFAULT NULL COMMENT '备注',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '规格值';


DROP TABLE IF EXISTS `product_sku`;
CREATE TABLE `product_sku`
(
    `id`                     bigint(20)                                                   NOT NULL AUTO_INCREMENT comment '商品 sku 编号，自增',
    `spu_id`                 bigint(20)                                                   NOT NULL COMMENT 'spu编号',
    `properties`             varchar(512)                                                          DEFAULT NULL COMMENT '属性数组，JSON 格式',
    `price`                  int(11)                                                      NOT NULL DEFAULT -1 COMMENT '商品价格，单位：分',
    `market_price`           int(11)                                                      NULL     DEFAULT NULL COMMENT '市场价，单位：分',
    `cost_price`             int(11)                                                      NOT NULL DEFAULT -1 COMMENT '成本价，单位： 分',
    `bar_code`               varchar(64)                                                           DEFAULT NULL COMMENT 'SKU 的条形码',
    `pic_url`                varchar(256)                                                          DEFAULT NULL COMMENT '图片地址',
    `stock`                  int(11)                                                      NULL     DEFAULT NULL COMMENT '库存',
    `weight`                 double                                                       NULL     DEFAULT NULL COMMENT '商品重量，单位：kg 千克',
    `volume`                 double                                                       NULL     DEFAULT NULL COMMENT '商品体积，单位：m^3 平米',
    `first_brokerage_price`  int(11)                                                      NULL     DEFAULT NULL COMMENT '一级分销的佣金，单位：分',
    `second_brokerage_price` int(11)                                                      NULL     DEFAULT NULL COMMENT '二级分销的佣金，单位：分',
    `sales_count`            int(11)                                                      NULL     DEFAULT NULL COMMENT '商品销量',
    `creator`                varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time`            datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time`            datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`              bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '商品sku';


DROP TABLE IF EXISTS `product_spu`;
CREATE TABLE `product_spu`
(
    `id`                   bigint(20)                                                     NOT NULL AUTO_INCREMENT COMMENT '商品 SPU 编号，自增',
    `name`                 varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '商品名称',
    `keyword`              varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '关键字',
    `introduction`         varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '商品简介',
    `description`          text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci          NOT NULL COMMENT '商品详情',
    `category_id`          bigint(20)                                                     NOT NULL COMMENT '商品分类编号',
    `brand_id`             int(11)                                                        NULL     DEFAULT NULL COMMENT '商品品牌编号',
    `pic_url`              varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci  NOT NULL COMMENT '商品封面图',
    `slider_pic_urls`      varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL     DEFAULT '' COMMENT '商品轮播图地址\n 数组，以逗号分隔\n 最多上传15张',
    `sort`                 int(11)                                                        NOT NULL DEFAULT 0 COMMENT '排序字段',
    `status`               tinyint(4)                                                     NOT NULL COMMENT '商品状态: 0 上架（开启） 1 下架（禁用）-1 回收',
    `spec_type`            bit(1)                                                         NOT NULL COMMENT '规格类型：0 单规格 1 多规格',
    `price`                int(11)                                                        NOT NULL DEFAULT -1 COMMENT '商品价格，单位使用：分',
    `market_price`         int(11)                                                        NOT NULL COMMENT '市场价，单位使用：分',
    `cost_price`           int(11)                                                        NOT NULL DEFAULT -1 COMMENT '成本价，单位： 分',
    `stock`                int(11)                                                        NOT NULL DEFAULT 0 COMMENT '库存',
    `delivery_types`       varchar(1000)                                                  NOT NULL COMMENT '配送方式数组',
    `delivery_template_id` bigint(20)                                                     NOT NULL COMMENT '物流配置模板编号',
    `give_integral`        int(11)                                                        NOT NULL COMMENT '赠送积分',
    `sub_commission_type`  bit(1)                                                         NOT NULL COMMENT '分销类型',
    `sales_count`          int(11)                                                        NULL     DEFAULT 0 COMMENT '商品销量',
    `virtual_sales_count`  int(11)                                                        NULL     DEFAULT 0 COMMENT '虚拟销量',
    `browse_count`         int(11)                                                        NULL     DEFAULT 0 COMMENT '商品点击量',
    `creator`              varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NULL     DEFAULT '' COMMENT '创建者',
    `create_time`          datetime(0)                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`              varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci   NULL     DEFAULT '' COMMENT '更新者',
    `update_time`          datetime(0)                                                    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`              bit(1)                                                         NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`            bigint(20)                                                     NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT = '商品spu';

DROP TABLE IF EXISTS `product_browse_history`;
CREATE TABLE `product_browse_history`
(
    `id`           bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '记录编号',
    `spu_id`       bigint(20)                                                            DEFAULT NULL COMMENT '商品 SPU 编号',
    `user_id`      bigint(20)                                                            DEFAULT NULL COMMENT '用户编号',
    `user_deleted` tinyint(1)                                                            DEFAULT NULL COMMENT '用户是否删除',
    `creator`      varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time`  datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`      varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time`  datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`      bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`    bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT ='商品浏览记录';

DROP TABLE IF EXISTS `product_favorite`;
CREATE TABLE `product_favorite`
(
    `id`          bigint(20)                                                   NOT NULL AUTO_INCREMENT COMMENT '记录编号',
    `spu_id`      bigint(20)                                                            DEFAULT NULL COMMENT '商品 SPU 编号',
    `user_id`     bigint(20)                                                            DEFAULT NULL COMMENT '用户编号',
    `creator`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT '' COMMENT '更新者',
    `update_time` datetime(0)                                                  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB COMMENT ='商品收藏';
DROP TABLE IF EXISTS `promotion_article_category`;
CREATE TABLE `promotion_article_category`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '文章分类编号',
    `name`        varchar(255)         DEFAULT NULL COMMENT '文章分类名称',
    `pic_url`     varchar(255)         DEFAULT NULL COMMENT '图标地址',
    `status`      int(11)              DEFAULT NULL COMMENT '状态',
    `sort`        int(11)              DEFAULT NULL COMMENT '排序',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='文章分类';

DROP TABLE IF EXISTS `promotion_article`;
CREATE TABLE `promotion_article`
(
    `id`               bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '文章管理编号',
    `category_id`      bigint(20)           DEFAULT NULL COMMENT '分类编号',
    `spu_id`           bigint(20)           DEFAULT NULL COMMENT '关联商品编号',
    `title`            varchar(255)         DEFAULT NULL COMMENT '文章标题',
    `author`           varchar(255)         DEFAULT NULL COMMENT '文章作者',
    `pic_url`          varchar(255)         DEFAULT NULL COMMENT '文章封面图片地址',
    `introduction`     varchar(255)         DEFAULT NULL COMMENT '文章简介',
    `browse_count`     int(11)              DEFAULT NULL COMMENT '浏览次数',
    `sort`             int(11)              DEFAULT NULL COMMENT '排序',
    `status`           int(11)              DEFAULT NULL COMMENT '状态',
    `recommend_hot`    tinyint(1)           DEFAULT NULL COMMENT '是否热门',
    `recommend_banner` tinyint(1)           DEFAULT NULL COMMENT '是否轮播图',
    `content`          longtext COMMENT '文章内容',
    `creator`          varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`          varchar(64) COMMENT '更新者',
    `update_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`          bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`        bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='文章管理';

DROP TABLE IF EXISTS `promotion_banner`;
CREATE TABLE `promotion_banner`
(
    `id`           bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `title`        varchar(255)         DEFAULT NULL COMMENT '标题',
    `url`          varchar(255)         DEFAULT NULL COMMENT '跳转链接',
    `pic_url`      varchar(255)         DEFAULT NULL COMMENT '图片链接',
    `sort`         int(11)              DEFAULT NULL COMMENT '排序',
    `status`       int(11)              DEFAULT NULL COMMENT '状态',
    `position`     int(11)              DEFAULT NULL COMMENT '定位',
    `memo`         varchar(255)         DEFAULT NULL COMMENT '备注',
    `browse_count` int(11)              DEFAULT NULL COMMENT '点击次数',
    `creator`      varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`      varchar(64) COMMENT '更新者',
    `update_time`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`      bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`    bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='轮播图';

DROP TABLE IF EXISTS `promotion_bargain_activity`;
CREATE TABLE `promotion_bargain_activity`
(
    `id`                  bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '砍价活动编号',
    `name`                varchar(255)         DEFAULT NULL COMMENT '砍价活动名称',
    `start_time`          datetime             DEFAULT NULL COMMENT '活动开始时间',
    `end_time`            datetime             DEFAULT NULL COMMENT '活动结束时间',
    `status`              int(11)              DEFAULT NULL COMMENT '活动状态',
    `spu_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `bargain_first_price` int(11)              DEFAULT NULL COMMENT '砍价起始价格，单位：分',
    `bargain_min_price`   int(11)              DEFAULT NULL COMMENT '砍价底价，单位：分',
    `stock`               int(11)              DEFAULT NULL COMMENT '砍价库存(剩余库存砍价时扣减)',
    `total_stock`         int(11)              DEFAULT NULL COMMENT '砍价总库存',
    `help_max_count`      int(11)              DEFAULT NULL COMMENT '砍价人数，需要多少人砍价才能成功',
    `bargain_count`       int(11)              DEFAULT NULL COMMENT '帮砍次数，单个活动用户可以帮砍的次数',
    `total_limit_count`   int(11)              DEFAULT NULL COMMENT '总限购数量',
    `random_min_price`    int(11)              DEFAULT NULL COMMENT '用户每次砍价的最小金额，单位：分',
    `random_max_price`    int(11)              DEFAULT NULL COMMENT '用户每次砍价的最大金额，单位：分',
    `creator`             varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='砍价活动';

DROP TABLE IF EXISTS `promotion_bargain_help`;
CREATE TABLE `promotion_bargain_help`
(
    `id`           bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `activity_id`  bigint(20)           DEFAULT NULL COMMENT '砍价活动编号',
    `record_id`    bigint(20)           DEFAULT NULL COMMENT '砍价记录编号',
    `user_id`      bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `reduce_price` int(11)              DEFAULT NULL COMMENT '减少价格，单位：分',
    `creator`      varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`      varchar(64) COMMENT '更新者',
    `update_time`  datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`      bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`    bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='砍价助力';

DROP TABLE IF EXISTS `promotion_bargain_record`;
CREATE TABLE `promotion_bargain_record`
(
    `id`                  bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`             bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `activity_id`         bigint(20)           DEFAULT NULL COMMENT '砍价活动编号',
    `spu_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `bargain_first_price` int(11)              DEFAULT NULL COMMENT '砍价起始价格，单位：分',
    `bargain_price`       int(11)              DEFAULT NULL COMMENT '当前砍价，单位：分',
    `status`              int(11)              DEFAULT NULL COMMENT '砍价状态',
    `end_time`            datetime             DEFAULT NULL COMMENT '结束时间',
    `order_id`            bigint(20)           DEFAULT NULL COMMENT '订单编号',
    `creator`             varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='砍价记录';

DROP TABLE IF EXISTS `promotion_combination_activity`;
CREATE TABLE `promotion_combination_activity`
(
    `id`                 bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '活动编号',
    `name`               varchar(255)         DEFAULT NULL COMMENT '拼团名称',
    `spu_id`             bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `total_limit_count`  int(11)              DEFAULT NULL COMMENT '总限购数量',
    `single_limit_count` int(11)              DEFAULT NULL COMMENT '单次限购数量',
    `start_time`         datetime             DEFAULT NULL COMMENT '开始时间',
    `end_time`           datetime             DEFAULT NULL COMMENT '结束时间',
    `user_size`          int(11)              DEFAULT NULL COMMENT '几人团',
    `virtual_group`      tinyint(1)           DEFAULT NULL COMMENT '虚拟成团',
    `status`             int(11)              DEFAULT NULL COMMENT '活动状态',
    `limit_duration`     int(11)              DEFAULT NULL COMMENT '限制时长（小时）',
    `creator`            varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`        datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`            varchar(64) COMMENT '更新者',
    `update_time`        datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`            bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`          bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='拼团活动';

DROP TABLE IF EXISTS `promotion_combination_product`;
CREATE TABLE `promotion_combination_product`
(
    `id`                  bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `activity_id`         bigint(20)           DEFAULT NULL COMMENT '拼团活动编号',
    `spu_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `combination_price`   int(11)              DEFAULT NULL COMMENT '拼团价格，单位分',
    `activity_status`     int(11)              DEFAULT NULL COMMENT '拼团商品状态',
    `activity_start_time` datetime             DEFAULT NULL COMMENT '活动开始时间点',
    `activity_end_time`   datetime             DEFAULT NULL COMMENT '活动结束时间点',
    `creator`             varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='拼团商品';


DROP TABLE IF EXISTS `promotion_combination_record`;
CREATE TABLE `promotion_combination_record`
(
    `id`                bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `activity_id`       bigint(20)           DEFAULT NULL COMMENT '拼团活动编号',
    `combination_price` int(11)              DEFAULT NULL COMMENT '拼团商品单价',
    `spu_id`            bigint(20)           DEFAULT NULL COMMENT 'SPU 编号',
    `spu_name`          varchar(255)         DEFAULT NULL COMMENT '商品名字',
    `pic_url`           varchar(255)         DEFAULT NULL COMMENT '商品图片',
    `sku_id`            bigint(20)           DEFAULT NULL COMMENT 'SKU 编号',
    `count`             int(11)              DEFAULT NULL COMMENT '购买的商品数量',
    `user_id`           bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `nickname`          varchar(255)         DEFAULT NULL COMMENT '用户昵称',
    `avatar`            varchar(255)         DEFAULT NULL COMMENT '用户头像',
    `head_id`           bigint(20)           DEFAULT NULL COMMENT '团长编号',
    `status`            int(11)              DEFAULT NULL COMMENT '开团状态',
    `order_id`          bigint(20)           DEFAULT NULL COMMENT '订单编号',
    `user_size`         int(11)              DEFAULT NULL COMMENT '开团需要人数',
    `user_count`        int(11)              DEFAULT NULL COMMENT '已加入拼团人数',
    `virtual_group`     tinyint(1)           DEFAULT NULL COMMENT '是否虚拟成团，默认为 false',
    `expire_time`       datetime             DEFAULT NULL COMMENT '过期时间',
    `start_time`        datetime             DEFAULT NULL COMMENT '开始时间 (订单付款后开始的时间)',
    `end_time`          datetime             DEFAULT NULL COMMENT '结束时间（成团时间/失败时间）',
    `creator`           varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`           varchar(64) COMMENT '更新者',
    `update_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`           bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`         bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='拼团记录';

DROP TABLE IF EXISTS `promotion_coupon`;
CREATE TABLE `promotion_coupon`
(
    `id`                   bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '优惠劵编号',
    `template_id`          bigint(20)           DEFAULT NULL COMMENT '优惠劵模板编',
    `name`                 varchar(255)         DEFAULT NULL COMMENT '优惠劵名',
    `status`               int(11)              DEFAULT NULL COMMENT '优惠码状态',
    `user_id`              bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `take_type`            int(11)              DEFAULT NULL COMMENT '领取类型m',
    `use_price`            int(11)              DEFAULT NULL COMMENT '是否设置满多少金额可用，单位：分',
    `valid_start_time`     datetime             DEFAULT NULL COMMENT '生效开始时间',
    `valid_end_time`       datetime             DEFAULT NULL COMMENT '生效结束时间',
    `product_scope`        int(11)              DEFAULT NULL COMMENT '商品范围',
    `product_scope_values` mediumtext COMMENT '商品范围编号的数组段',
    `discount_type`        int(11)              DEFAULT NULL COMMENT '折扣类型',
    `discount_percent`     int(11)              DEFAULT NULL COMMENT '折扣百分比，',
    `discount_price`       int(11)              DEFAULT NULL COMMENT '优惠金额，单位：分',
    `discount_limit_price` int(11)              DEFAULT NULL COMMENT '折扣上限',
    `use_order_id`         bigint(20)           DEFAULT NULL COMMENT '使用订单号',
    `use_time`             datetime             DEFAULT NULL COMMENT '使用时间',
    `creator`              varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`              varchar(64) COMMENT '更新者',
    `update_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`              bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`            bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='优惠劵';


DROP TABLE IF EXISTS `promotion_coupon_template`;
CREATE TABLE `promotion_coupon_template`
(
    `id`                   bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '模板编号，自增唯一',
    `name`                 varchar(255)         DEFAULT NULL COMMENT '优惠劵名',
    `status`               int(11)              DEFAULT NULL COMMENT '状态',
    `total_count`          int(11)              DEFAULT NULL COMMENT '发放数量，-1 表示不限制发放数量',
    `take_limit_count`     int(11)              DEFAULT NULL COMMENT '每人限领个数，-1 表示不限制',
    `take_type`            int(11)              DEFAULT NULL COMMENT '领取方式',
    `use_price`            int(11)              DEFAULT NULL COMMENT '是否设置满多少金额可用，单位：分，0 表示不限制',
    `product_scope`        int(11)              DEFAULT NULL COMMENT '商品范围',
    `product_scope_values` mediumtext COMMENT '商品范围编号的数组',
    `validity_type`        int(11)              DEFAULT NULL COMMENT '生效日期类型',
    `valid_start_time`     datetime             DEFAULT NULL COMMENT '固定日期 - 生效开始时间',
    `valid_end_time`       datetime             DEFAULT NULL COMMENT '固定日期 - 生效结束时间',
    `fixed_start_term`     int(11)              DEFAULT NULL COMMENT '领取日期 - 开始天数',
    `fixed_end_term`       int(11)              DEFAULT NULL COMMENT '领取日期 - 结束天数',
    `discount_type`        int(11)              DEFAULT NULL COMMENT '折扣类型',
    `discount_percent`     int(11)              DEFAULT NULL COMMENT '折扣百分比',
    `discount_price`       int(11)              DEFAULT NULL COMMENT '优惠金额，单位：分',
    `discount_limit_price` int(11)              DEFAULT NULL COMMENT '折扣上限',
    `take_count`           int(11)              DEFAULT NULL COMMENT '领取优惠券的数量',
    `use_count`            int(11)              DEFAULT NULL COMMENT '使用优惠券的次数',
    `description`          varchar(255)         default null comment '优惠券说明',
    `creator`              varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`              varchar(64) COMMENT '更新者',
    `update_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`              bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`            bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='优惠劵模板';

DROP TABLE IF EXISTS `promotion_discount_activity`;
CREATE TABLE `promotion_discount_activity`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '活动编号，主键自增',
    `name`        varchar(255)         DEFAULT NULL COMMENT '活动标题',
    `status`      int(11)              DEFAULT NULL COMMENT '状态',
    `start_time`  datetime             DEFAULT NULL COMMENT '开始时间',
    `end_time`    datetime             DEFAULT NULL COMMENT '结束时间',
    `remark`      varchar(255)         DEFAULT NULL COMMENT '备注',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='限时折扣活动';


DROP TABLE IF EXISTS `promotion_discount_product`;
CREATE TABLE `promotion_discount_product`
(
    `id`                  bigint(20)   NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `activity_id`         bigint(20)            DEFAULT NULL COMMENT '限时折扣活动的编号',
    `spu_id`              bigint(20)            DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`              bigint(20)            DEFAULT NULL COMMENT '商品 SKU 编号',
    `discount_type`       int(11)               DEFAULT NULL COMMENT '折扣类型',
    `discount_percent`    int(11)               DEFAULT NULL COMMENT '折扣百分比',
    `discount_price`      int(11)               DEFAULT NULL COMMENT '优惠金额，单位：分',
    `activity_name`       varchar(255) null comment '活动标题',
    `activity_status`     int(11)               DEFAULT NULL COMMENT '活动状态',
    `activity_start_time` datetime              DEFAULT NULL COMMENT '活动开始时间点',
    `activity_end_time`   datetime              DEFAULT NULL COMMENT '活动结束时间点',
    `creator`             varchar(64)           DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='限时折扣商品';

DROP TABLE IF EXISTS `promotion_diy_page`;
CREATE TABLE `promotion_diy_page`
(
    `id`               bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '装修页面编号',
    `template_id`      bigint(20)           DEFAULT NULL COMMENT '装修模板编号',
    `name`             varchar(255)         DEFAULT NULL COMMENT '页面名称',
    `remark`           varchar(255)         DEFAULT NULL COMMENT '备注',
    `preview_pic_urls` mediumtext COMMENT '预览图，多个逗号分隔',
    `property`         longtext COMMENT '页面属性，JSON 格式',
    `creator`          varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`          varchar(64) COMMENT '更新者',
    `update_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`          bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`        bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='装修页面';


DROP TABLE IF EXISTS `promotion_diy_template`;
CREATE TABLE `promotion_diy_template`
(
    `id`               bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '装修模板编号',
    `name`             varchar(255)         DEFAULT NULL COMMENT '模板名称',
    `used`             tinyint(1)           DEFAULT NULL COMMENT '是否使用',
    `used_time`        datetime             DEFAULT NULL COMMENT '使用时间',
    `remark`           varchar(255)         DEFAULT NULL COMMENT '备注',
    `preview_pic_urls` mediumtext COMMENT '预览图',
    `property`         longtext COMMENT 'uni-app 底部导航属性，JSON 格式',
    `creator`          varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`          varchar(64) COMMENT '更新者',
    `update_time`      datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`          bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`        bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='装修模板';


DROP TABLE IF EXISTS `promotion_reward_activity`;
CREATE TABLE `promotion_reward_activity`
(
    `id`                   bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '活动编号，主键自增',
    `name`                 varchar(255)         DEFAULT NULL COMMENT '活动标题',
    `status`               int(11)              DEFAULT NULL COMMENT '状态',
    `start_time`           datetime             DEFAULT NULL COMMENT '开始时间',
    `end_time`             datetime             DEFAULT NULL COMMENT '结束时间',
    `remark`               varchar(255)         DEFAULT NULL COMMENT '备注',
    `condition_type`       int(11)              DEFAULT NULL COMMENT '条件类型',
    `product_scope`        int(11)              DEFAULT NULL COMMENT '商品范围',
    `product_scope_values` mediumtext COMMENT '商品 SPU 编号的数组',
    `rules`                mediumtext COMMENT '优惠规则的数组',
    `creator`              varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`              varchar(64) COMMENT '更新者',
    `update_time`          datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`              bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`            bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='满减送活动';

DROP TABLE IF EXISTS `promotion_seckill_activity`;
CREATE TABLE `promotion_seckill_activity`
(
    `id`                 bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '秒杀活动编号',
    `spu_id`             bigint(20)           DEFAULT NULL COMMENT '秒杀活动商品',
    `name`               varchar(255)         DEFAULT NULL COMMENT '秒杀活动名称',
    `status`             int(11)              DEFAULT NULL COMMENT '活动状态',
    `remark`             varchar(255)         DEFAULT NULL COMMENT '备注',
    `start_time`         datetime             DEFAULT NULL COMMENT '活动开始时间',
    `end_time`           datetime             DEFAULT NULL COMMENT '活动结束时间',
    `sort`               int(11)              DEFAULT NULL COMMENT '排序',
    `config_ids`         mediumtext COMMENT '秒杀时段 id',
    `total_limit_count`  int(11)              DEFAULT NULL COMMENT '总限购数量',
    `single_limit_count` int(11)              DEFAULT NULL COMMENT '单次限够数量',
    `stock`              int(11)              DEFAULT NULL COMMENT '秒杀库存(剩余库存秒杀时扣减)',
    `total_stock`        int(11)              DEFAULT NULL COMMENT '秒杀总库存',
    `creator`            varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`        datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`            varchar(64) COMMENT '更新者',
    `update_time`        datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`            bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`          bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='秒杀活动';


DROP TABLE IF EXISTS `promotion_seckill_config`;
CREATE TABLE `promotion_seckill_config`
(
    `id`              bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`            varchar(255)         DEFAULT NULL COMMENT '秒杀时段名称',
    `start_time`      varchar(255)         DEFAULT NULL COMMENT '开始时间点',
    `end_time`        varchar(255)         DEFAULT NULL COMMENT '结束时间点',
    `slider_pic_urls` mediumtext COMMENT '秒杀轮播图',
    `status`          int(11)              DEFAULT NULL COMMENT '状态',
    `creator`         varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`         varchar(64) COMMENT '更新者',
    `update_time`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`         bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`       bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='秒杀时段';


DROP TABLE IF EXISTS `promotion_seckill_product`;
CREATE TABLE `promotion_seckill_product`
(
    `id`                  bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '秒杀参与商品编号',
    `activity_id`         bigint(20)           DEFAULT NULL COMMENT '秒杀活动 id',
    `config_ids`          mediumtext COMMENT '秒杀时段 id',
    `spu_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`              bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `seckill_price`       int(11)              DEFAULT NULL COMMENT '秒杀金额，单位：分',
    `stock`               int(11)              DEFAULT NULL COMMENT '秒杀库存',
    `activity_status`     int(11)              DEFAULT NULL COMMENT '秒杀商品状态',
    `activity_start_time` datetime             DEFAULT NULL COMMENT '活动开始时间点',
    `activity_end_time`   datetime             DEFAULT NULL COMMENT '活动结束时间点',
    `creator`             varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='秒杀参与商品';
DROP TABLE IF EXISTS `trade_after_sale`;
CREATE TABLE `trade_after_sale`
(
    `id`                bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '售后编号，主键自增',
    `no`                varchar(20)          DEFAULT NULL COMMENT '售后单号',
    `status`            int(11)              DEFAULT NULL COMMENT '退款状态',
    `way`               int(11)              DEFAULT NULL COMMENT '售后方式',
    `type`              int(11)              DEFAULT NULL COMMENT '售后类型',
    `user_id`           bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `apply_reason`      varchar(255)         DEFAULT NULL COMMENT '申请原因',
    `apply_description` varchar(255)         DEFAULT NULL COMMENT '补充描述',
    `apply_pic_urls`    text COMMENT '补充凭证图片，数组，以逗号分隔',
    `order_id`          bigint(20)           DEFAULT NULL COMMENT '交易订单编号',
    `order_no`          varchar(20)          DEFAULT NULL COMMENT '订单流水号',
    `order_item_id`     bigint(20)           DEFAULT NULL COMMENT '交易订单项编号',
    `spu_id`            bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `spu_name`          varchar(255)         DEFAULT NULL COMMENT '商品 SPU 名称',
    `sku_id`            bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `properties`        text COMMENT '属性数组，JSON 格式',
    `pic_url`           varchar(255)         DEFAULT NULL COMMENT '商品图片',
    `count`             int(11)              DEFAULT NULL COMMENT '退货商品数量',
    `audit_time`        datetime             DEFAULT NULL COMMENT '审批时间',
    `audit_user_id`     bigint(20)           DEFAULT NULL COMMENT '审批人',
    `audit_reason`      varchar(255)         DEFAULT NULL COMMENT '审批备注',
    `refund_price`      int(11)              DEFAULT NULL COMMENT '退款金额，单位：分',
    `pay_refund_id`     bigint(20)           DEFAULT NULL COMMENT '支付退款编号',
    `refund_time`       datetime             DEFAULT NULL COMMENT '退款时间',
    `logistics_id`      bigint(20)           DEFAULT NULL COMMENT '退货物流公司编号',
    `logistics_no`      varchar(20)          DEFAULT NULL COMMENT '退货物流单号',
    `delivery_time`     datetime             DEFAULT NULL COMMENT '退货时间',
    `receive_time`      datetime             DEFAULT NULL COMMENT '收货时间',
    `receive_reason`    varchar(255)         DEFAULT NULL COMMENT '收货备注',
    `creator`           varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`           varchar(64) COMMENT '更新者',
    `update_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`           bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`         bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='售后订单';


DROP TABLE IF EXISTS `trade_after_sale_log`;
CREATE TABLE `trade_after_sale_log`
(
    `id`            bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`       bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `user_type`     int(11)              DEFAULT NULL COMMENT '用户类型',
    `after_sale_id` bigint(20)           DEFAULT NULL COMMENT '售后编号',
    `before_status` int(11)              DEFAULT NULL COMMENT '操作前状态',
    `after_status`  int(11)              DEFAULT NULL COMMENT '操作后状态',
    `operate_type`  int(11)              DEFAULT NULL COMMENT '操作类型',
    `content`       varchar(255)         DEFAULT NULL COMMENT '操作明细',
    `creator`       varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`       varchar(64) COMMENT '更新者',
    `update_time`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`       bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`     bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='交易售后日志';


DROP TABLE IF EXISTS `trade_brokerage_record`;
CREATE TABLE `trade_brokerage_record`
(
    `id`                int(11)     NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`           bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `biz_id`            varchar(255)         DEFAULT NULL COMMENT '业务编号',
    `biz_type`          int(11)              DEFAULT NULL COMMENT '业务类型',
    `title`             varchar(255)         DEFAULT NULL COMMENT '标题',
    `description`       varchar(255)         DEFAULT NULL COMMENT '说明',
    `price`             int(11)              DEFAULT NULL COMMENT '金额',
    `total_price`       int(11)              DEFAULT NULL COMMENT '当前总佣金',
    `status`            int(11)              DEFAULT NULL COMMENT '状态',
    `frozen_days`       int(11)              DEFAULT NULL COMMENT '冻结时间（天）',
    `unfreeze_time`     datetime             DEFAULT NULL COMMENT '解冻时间',
    `source_user_level` int(11)              DEFAULT NULL COMMENT '来源用户等级',
    `source_user_id`    bigint(20)           DEFAULT NULL COMMENT '来源用户编号',
    `creator`           varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`           varchar(64) COMMENT '更新者',
    `update_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`           bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`         bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='佣金记录';


DROP TABLE IF EXISTS `trade_brokerage_user`;
CREATE TABLE `trade_brokerage_user`
(
    `id`                bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '用户编号',
    `bind_user_id`      bigint(20)           DEFAULT NULL COMMENT '推广员编号',
    `bind_user_time`    datetime             DEFAULT NULL COMMENT '推广员绑定时间',
    `brokerage_enabled` tinyint(1)           DEFAULT NULL COMMENT '是否有分销资格',
    `brokerage_time`    datetime             DEFAULT NULL COMMENT '成为分销员时间',
    `brokerage_price`   int(11)              DEFAULT NULL COMMENT '可用佣金',
    `frozen_price`      int(11)              DEFAULT NULL COMMENT '冻结佣金',
    `creator`           varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`           varchar(64) COMMENT '更新者',
    `update_time`       datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`           bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`         bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='分销用户';


DROP TABLE IF EXISTS `trade_brokerage_withdraw`;
CREATE TABLE `trade_brokerage_withdraw`
(
    `id`                  bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`             bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `price`               int(11)              DEFAULT NULL COMMENT '提现金额，单位：分',
    `fee_price`           int(11)              DEFAULT NULL COMMENT '提现手续费，单位：分',
    `total_price`         int(11)              DEFAULT NULL COMMENT '当前总佣金，单位：分',
    `type`                int(11)              DEFAULT NULL COMMENT '提现类型',
    `name`                varchar(255)         DEFAULT NULL COMMENT '真实姓名',
    `account_no`          varchar(255)         DEFAULT NULL COMMENT '账号',
    `bank_name`           varchar(255)         DEFAULT NULL COMMENT '银行名称',
    `bank_address`        varchar(255)         DEFAULT NULL COMMENT '开户地址',
    `account_qr_code_url` varchar(255)         DEFAULT NULL COMMENT '收款码',
    `status`              int(11)              DEFAULT NULL COMMENT '状态',
    `audit_reason`        varchar(255)         DEFAULT NULL COMMENT '审核驳回原因',
    `audit_time`          datetime             DEFAULT NULL COMMENT '审核时间',
    `remark`              varchar(255)         DEFAULT NULL COMMENT '备注',
    `creator`             varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`             varchar(64) COMMENT '更新者',
    `update_time`         datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`             bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`           bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='佣金提现';


DROP TABLE IF EXISTS `trade_cart`;
CREATE TABLE `trade_cart`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，唯一自增',
    `user_id`     bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `spu_id`      bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `sku_id`      bigint(20)           DEFAULT NULL COMMENT '商品 SKU 编号',
    `count`       int(11)              DEFAULT NULL COMMENT '商品购买数量',
    `selected`    tinyint(1)           DEFAULT NULL COMMENT '是否选中',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='购物车的商品信息';


DROP TABLE IF EXISTS `trade_config`;
CREATE TABLE `trade_config`
(
    `id`                             bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '自增主键',
    `after_sale_refund_reasons`      json                 DEFAULT NULL COMMENT '售后的退款理由',
    `after_sale_return_reasons`      json                 DEFAULT NULL COMMENT '售后的退货理由',
    `delivery_express_free_enabled`  tinyint(1)           DEFAULT NULL COMMENT '是否启用全场包邮',
    `delivery_express_free_price`    int(11)              DEFAULT NULL COMMENT '全场包邮的最小金额，单位：分',
    `delivery_pick_up_enabled`       tinyint(1)           DEFAULT NULL COMMENT '是否开启自提',
    `brokerage_enabled`              tinyint(1)           DEFAULT NULL COMMENT '是否启用分佣',
    `brokerage_enabled_condition`    int(11)              DEFAULT NULL COMMENT '分佣模式',
    `brokerage_bind_mode`            int(11)              DEFAULT NULL COMMENT '分销关系绑定模式',
    `brokerage_poster_urls`          json                 DEFAULT NULL COMMENT '分销海报图地址数组',
    `brokerage_first_percent`        int(11)              DEFAULT NULL COMMENT '一级返佣比例',
    `brokerage_second_percent`       int(11)              DEFAULT NULL COMMENT '二级返佣比例',
    `brokerage_withdraw_min_price`   int(11)              DEFAULT NULL COMMENT '用户提现最低金额',
    `brokerage_withdraw_fee_percent` int(11)              DEFAULT NULL COMMENT '用户提现手续费百分比',
    `brokerage_frozen_days`          int(11)              DEFAULT NULL COMMENT '佣金冻结时间(天)',
    `brokerage_withdraw_types`       json                 DEFAULT NULL COMMENT '提现方式',
    `creator`                        varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`                    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                        varchar(64) COMMENT '更新者',
    `update_time`                    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                        bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`                      bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='交易中心配置';


DROP TABLE IF EXISTS `trade_delivery_express`;
CREATE TABLE `trade_delivery_express`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
    `code`        varchar(255)         DEFAULT NULL COMMENT '快递公司 code',
    `name`        varchar(255)         DEFAULT NULL COMMENT '快递公司名称',
    `logo`        varchar(255)         DEFAULT NULL COMMENT '快递公司 logo',
    `sort`        int(11)              DEFAULT NULL COMMENT '排序',
    `status`      int(11)              DEFAULT NULL COMMENT '状态',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='快递公司';


DROP TABLE IF EXISTS `trade_delivery_express_template_charge`;
CREATE TABLE `trade_delivery_express_template_charge`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
    `template_id` bigint(20)           DEFAULT NULL COMMENT '配送模板编号',
    `area_ids`    longtext             DEFAULT NULL COMMENT '配送区域编号列表',
    `charge_mode` int(11)              DEFAULT NULL COMMENT '配送计费方式',
    `start_count` double               DEFAULT NULL COMMENT '首件数量(件数,重量，或体积)',
    `start_price` int(11)              DEFAULT NULL COMMENT '起步价，单位：分',
    `extra_count` double               DEFAULT NULL COMMENT '续件数量(件, 重量，或体积)',
    `extra_price` int(11)              DEFAULT NULL COMMENT '额外价，单位：分',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='快递运费模板计费配置';


DROP TABLE IF EXISTS `trade_delivery_express_template`;
CREATE TABLE `trade_delivery_express_template`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
    `name`        varchar(255)         DEFAULT NULL COMMENT '模板名称',
    `charge_mode` int(11)              DEFAULT NULL COMMENT '配送计费方式',
    `sort`        int(11)              DEFAULT NULL COMMENT '排序',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='快递运费模板';

DROP TABLE IF EXISTS `trade_delivery_express_template_free`;
CREATE TABLE `trade_delivery_express_template_free`
(
    `id`          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `template_id` bigint(20)           DEFAULT NULL COMMENT '配送模板编号',
    `area_ids`    longtext             DEFAULT NULL COMMENT '配送区域编号列表',
    `free_price`  int(11)              DEFAULT NULL COMMENT '包邮金额，单位：分',
    `free_count`  int(11)              DEFAULT NULL COMMENT '包邮件数',
    `creator`     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='快递运费模板包邮配置';


DROP TABLE IF EXISTS `trade_delivery_pick_up_store`;
CREATE TABLE `trade_delivery_pick_up_store`
(
    `id`             bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号',
    `name`           varchar(255)         DEFAULT NULL COMMENT '门店名称',
    `introduction`   varchar(255)         DEFAULT NULL COMMENT '门店简介',
    `phone`          varchar(255)         DEFAULT NULL COMMENT '门店手机',
    `area_id`        int(11)              DEFAULT NULL COMMENT '区域编号',
    `detail_address` varchar(255)         DEFAULT NULL COMMENT '门店详细地址',
    `logo`           varchar(255)         DEFAULT NULL COMMENT '门店 logo',
    `opening_time`   time                 DEFAULT NULL COMMENT '营业开始时间',
    `closing_time`   time                 DEFAULT NULL COMMENT '营业结束时间',
    `latitude`       double               DEFAULT NULL COMMENT '纬度',
    `longitude`      double               DEFAULT NULL COMMENT '经度',
    `status`         int(11)              DEFAULT NULL COMMENT '门店状态',
    `creator`        varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`        varchar(64) COMMENT '更新者',
    `update_time`    datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`        bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`      bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='自提门店';


DROP TABLE IF EXISTS `trade_delivery_pick_up_store_staff`;
CREATE TABLE `trade_delivery_pick_up_store_staff`
(
    `id`            bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，自增',
    `store_id`      bigint(20)           DEFAULT NULL COMMENT '自提门店编号',
    `admin_user_id` bigint(20)           DEFAULT NULL COMMENT '管理员用户id',
    `status`        int(11)              DEFAULT NULL COMMENT '状态',
    `creator`       varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`       varchar(64) COMMENT '更新者',
    `update_time`   datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`       bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`     bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='自提门店店员';


DROP TABLE IF EXISTS `trade_order`;
CREATE TABLE `trade_order`
(
    `id`                          bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '订单编号，主键自增',
    `no`                          varchar(50)          DEFAULT NULL COMMENT '订单流水号',
    `type`                        int(11)              DEFAULT NULL COMMENT '订单类型',
    `terminal`                    int(11)              DEFAULT NULL COMMENT '订单来源',
    `user_id`                     bigint(20)           DEFAULT NULL COMMENT '用户编号',
    `user_ip`                     varchar(50)          DEFAULT NULL COMMENT '用户 IP',
    `user_remark`                 varchar(255)         DEFAULT NULL COMMENT '用户备注',
    `status`                      int(11)              DEFAULT NULL COMMENT '订单状态',
    `product_count`               int(11)              DEFAULT NULL COMMENT '购买的商品数量',
    `finish_time`                 datetime             DEFAULT NULL COMMENT '订单完成时间',
    `cancel_time`                 datetime             DEFAULT NULL COMMENT '订单取消时间',
    `cancel_type`                 int(11)              DEFAULT NULL COMMENT '取消类型',
    `remark`                      varchar(255)         DEFAULT NULL COMMENT '商家备注',
    `comment_status`              tinyint(1)           DEFAULT NULL COMMENT '是否评价',
    `brokerage_user_id`           bigint(20)           DEFAULT NULL COMMENT '推广人编号',
    `pay_order_id`                bigint(20)           DEFAULT NULL COMMENT '支付订单编号',
    `pay_status`                  tinyint(1)           DEFAULT NULL COMMENT '是否已支付',
    `pay_time`                    datetime             DEFAULT NULL COMMENT '付款时间',
    `pay_channel_code`            varchar(50)          DEFAULT NULL COMMENT '支付渠道',
    `total_price`                 int(11)              DEFAULT NULL COMMENT '商品原价，单位：分',
    `discount_price`              int(11)              DEFAULT NULL COMMENT '优惠金额，单位：分',
    `delivery_price`              int(11)              DEFAULT NULL COMMENT '运费金额，单位：分',
    `adjust_price`                int(11)              DEFAULT NULL COMMENT '订单调价，单位：分',
    `pay_price`                   int(11)              DEFAULT NULL COMMENT '应付金额（总），单位：分',
    `delivery_type`               int(11)              DEFAULT NULL COMMENT '配送方式',
    `logistics_id`                bigint(20)           DEFAULT NULL COMMENT '发货物流公司编号',
    `logistics_no`                varchar(50)          DEFAULT NULL COMMENT '发货物流单号',
    `delivery_time`               datetime             DEFAULT NULL COMMENT '发货时间',
    `receive_time`                datetime             DEFAULT NULL COMMENT '收货时间',
    `receiver_name`               varchar(50)          DEFAULT NULL COMMENT '收件人名称',
    `receiver_mobile`             varchar(20)          DEFAULT NULL COMMENT '收件人手机',
    `receiver_area_id`            int(11)              DEFAULT NULL COMMENT '收件人地区编号',
    `receiver_detail_address`     varchar(255)         DEFAULT NULL COMMENT '收件人详细地址',
    `pick_up_store_id`            bigint(20)           DEFAULT NULL COMMENT '自提门店编号',
    `pick_up_verify_code`         varchar(50)          DEFAULT NULL COMMENT '自提核销码',
    `refund_status`               int(11)              DEFAULT NULL COMMENT '售后状态',
    `refund_price`                int(11)              DEFAULT NULL COMMENT '退款金额，单位：分',
    `coupon_id`                   bigint(20)           DEFAULT NULL COMMENT '优惠劵编号',
    `coupon_price`                int(11)              DEFAULT NULL COMMENT '优惠劵减免金额，单位：分',
    `use_point`                   int(11)              DEFAULT NULL COMMENT '使用的积分',
    `point_price`                 int(11)              DEFAULT NULL COMMENT '积分抵扣的金额，单位：分',
    `give_point`                  int(11)              DEFAULT NULL COMMENT '赠送的积分',
    `refund_point`                int(11)              DEFAULT NULL COMMENT '退还的使用的积分',
    `give_coupon_template_counts` JSON                 default null COMMENT '赠送的优惠劵',
    `give_coupon_ids`             longtext             default null comment '赠送的优惠劵编号',
    `vip_price`                   int(11)              DEFAULT NULL COMMENT 'VIP 减免金额，单位：分',
    `seckill_activity_id`         bigint(20)           DEFAULT NULL COMMENT '秒杀活动编号',
    `bargain_activity_id`         bigint(20)           DEFAULT NULL COMMENT '砍价活动编号',
    `bargain_record_id`           bigint(20)           DEFAULT NULL COMMENT '砍价记录编号',
    `combination_activity_id`     bigint(20)           DEFAULT NULL COMMENT '拼团活动编号',
    `combination_head_id`         bigint(20)           DEFAULT NULL COMMENT '拼团团长编号',
    `combination_record_id`       bigint(20)           DEFAULT NULL COMMENT '拼团记录编号',
    `creator`                     varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`                 datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                     varchar(64) COMMENT '更新者',
    `update_time`                 datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                     bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`                   bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB COMMENT ='交易订单';


DROP TABLE IF EXISTS `trade_order_item`;
CREATE TABLE trade_order_item
(
    `id`                BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`           BIGINT(20)   NOT NULL COMMENT '用户编号',
    `order_id`          BIGINT(20)   NOT NULL COMMENT '订单编号',
    `cart_id`           BIGINT(20)   NULL COMMENT '购物车项编号',
    `spu_id`            BIGINT(20)   NOT NULL COMMENT '商品 SPU 编号',
    `spu_name`          VARCHAR(255) NOT NULL COMMENT '商品 SPU 名称',
    `sku_id`            BIGINT(20)   NOT NULL COMMENT '商品 SKU 编号',
    `properties`        JSON COMMENT '属性数组，JSON 格式',
    `pic_url`           VARCHAR(255) NOT NULL COMMENT '商品图片',
    `count`             INT(11)      NOT NULL COMMENT '购买数量',
    `comment_status`    TINYINT(1)   NOT NULL COMMENT '是否评价，1 - 已评价，0 - 未评价',
    `price`             INT(11)      NOT NULL COMMENT '商品原价（单），单位：分',
    `discount_price`    INT(11)      NOT NULL COMMENT '优惠金额（总），单位：分',
    `delivery_price`    INT(11)      NOT NULL COMMENT '运费金额（总），单位：分',
    `adjust_price`      INT(11)      NOT NULL COMMENT '订单调价（总），单位：分，正数为加价，负数为减价',
    `pay_price`         INT(11)      NOT NULL COMMENT '应付金额（总），单位：分，= price * count - coupon_price - point_price - discount_price + delivery_price + adjust_price - vip_price',
    `coupon_price`      INT(11)      NOT NULL COMMENT '优惠券减免金额，单位：分',
    `point_price`       INT(11)      NOT NULL COMMENT '积分抵扣的金额，单位：分',
    `use_point`         INT(11)      NOT NULL COMMENT '使用的积分，目的：用于后续取消或者售后订单时，需要归还赠送',
    `give_point`        INT(11)      NOT NULL COMMENT '赠送的积分，目的：用于后续取消或者售后订单时，需要扣减赠送',
    `vip_price`         INT(11)      NOT NULL COMMENT 'VIP 减免金额，单位：分',
    `after_sale_id`     BIGINT(20) COMMENT '售后单编号，关联 AfterSaleDO 的 id 字段',
    `after_sale_status` INT(11)      NOT NULL COMMENT '售后状态',
    `creator`           varchar(64)           DEFAULT '' COMMENT '创建者',
    `create_time`       datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`           varchar(64) COMMENT '更新者',
    `update_time`       datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`           bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`         bigint(20)   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='交易订单项';


DROP TABLE IF EXISTS `trade_order_log`;
CREATE TABLE trade_order_log
(
    `id`            BIGINT(20)   NOT NULL AUTO_INCREMENT COMMENT '编号',
    `user_id`       BIGINT(20)   NOT NULL COMMENT '用户编号',
    `user_type`     INT(11)      NOT NULL COMMENT '用户类型',
    `order_id`      BIGINT(20)   NOT NULL COMMENT '订单号段',
    `before_status` INT(11)      NOT NULL COMMENT '操作前状态',
    `after_status`  INT(11)      NOT NULL COMMENT '操作后状态',
    `operate_type`  INT(11)      NOT NULL COMMENT '操作类型',
    `content`       VARCHAR(255) NOT NULL COMMENT '订单日志信息',
    `creator`       varchar(64)           DEFAULT '' COMMENT '创建者',
    `create_time`   datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`       varchar(64) COMMENT '更新者',
    `update_time`   datetime(0)  NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`       bit(1)       NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`     bigint(20)   NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='订单日志表';
DROP TABLE IF EXISTS `product_statistics`;
CREATE TABLE `product_statistics`
(
    `id`                      bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `time`                    date                 DEFAULT NULL COMMENT '统计日期',
    `spu_id`                  bigint(20)           DEFAULT NULL COMMENT '商品 SPU 编号',
    `browse_count`            int(11)              DEFAULT NULL COMMENT '浏览量',
    `browse_user_count`       int(11)              DEFAULT NULL COMMENT '访客量',
    `favorite_count`          int(11)              DEFAULT NULL COMMENT '收藏数量',
    `cart_count`              int(11)              DEFAULT NULL COMMENT '加购数量',
    `order_count`             int(11)              DEFAULT NULL COMMENT '下单件数',
    `order_pay_count`         int(11)              DEFAULT NULL COMMENT '支付件数',
    `order_pay_price`         int(11)              DEFAULT NULL COMMENT '支付金额，单位：分',
    `after_sale_count`        int(11)              DEFAULT NULL COMMENT '退款件数',
    `after_sale_refund_price` int(11)              DEFAULT NULL COMMENT '退款金额，单位：分',
    `browse_convert_percent`  int(11)              DEFAULT NULL COMMENT '访客支付转化率（百分比）',
    `creator`                 varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`             datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                 varchar(64) COMMENT '更新者',
    `update_time`             datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                 bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`               bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='商品统计';

DROP TABLE IF EXISTS `trade_statistics`;
CREATE TABLE `trade_statistics`
(
    `id`                         bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `time`                       datetime             DEFAULT NULL COMMENT '统计日期',
    `order_create_count`         int(11)              DEFAULT NULL COMMENT '创建订单数',
    `order_pay_count`            int(11)              DEFAULT NULL COMMENT '支付订单商品数',
    `order_pay_price`            int(11)              DEFAULT NULL COMMENT '总支付金额，单位：分',
    `after_sale_count`           int(11)              DEFAULT NULL COMMENT '退款订单数',
    `after_sale_refund_price`    int(11)              DEFAULT NULL COMMENT '总退款金额，单位：分',
    `brokerage_settlement_price` int(11)              DEFAULT NULL COMMENT '佣金金额（已结算），单位：分',
    `wallet_pay_price`           int(11)              DEFAULT NULL COMMENT '总支付金额（余额），单位：分',
    `recharge_pay_count`         int(11)              DEFAULT NULL COMMENT '充值订单数',
    `recharge_pay_price`         int(11)              DEFAULT NULL COMMENT '充值金额，单位：分',
    `recharge_refund_count`      int(11)              DEFAULT NULL COMMENT '充值退款订单数',
    `recharge_refund_price`      int(11)              DEFAULT NULL COMMENT '充值退款金额，单位：分',
    `creator`                    varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`                datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                    varchar(64) COMMENT '更新者',
    `update_time`                datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                    bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`                  bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='交易统计';

DROP TABLE IF EXISTS `promotion_kefu_conversation`;
CREATE TABLE `promotion_kefu_conversation`
(
    `id`                         bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `user_id`                    bigint(20)  NOT NULL COMMENT '会话所属用户',
    `last_message_time`          datetime             DEFAULT NULL COMMENT '最后聊天时间',
    `last_message_content`       varchar(255)         DEFAULT NULL COMMENT '最后聊天内容',
    `last_message_content_type`  int(11)              DEFAULT NULL COMMENT '最后发送的消息类型',
    `admin_pinned`               tinyint(1)           DEFAULT NULL COMMENT '管理端置顶',
    `user_deleted`               tinyint(1)           DEFAULT 0 COMMENT '用户是否可见',
    `admin_deleted`              tinyint(1)           DEFAULT 0 COMMENT '管理员是否可见',
    `admin_unread_message_count` int(11)              DEFAULT 0 COMMENT '管理员未读消息数',
    `creator`                    varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`                datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`                    varchar(64) COMMENT '更新者',
    `update_time`                datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`                    bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`                  bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='客服会话';

DROP TABLE IF EXISTS `promotion_kefu_message`;
CREATE TABLE `promotion_kefu_message`
(
    `id`              bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `conversation_id` bigint(20)  NOT NULL COMMENT '会话编号',
    `sender_id`       bigint(20)           default NULL COMMENT '发送人编号',
    `sender_type`     int(2)               default NULL COMMENT '发送人类型',
    `receiver_id`     bigint(20)           default NULL COMMENT '接收人编号',
    `receiver_type`   int(2)               default NULL COMMENT '接收人类型',
    `content_type`    int(2)      NOT NULL COMMENT '消息类型',
    `content`         longtext    NOT NULL COMMENT '消息',
    `read_status`     tinyint(1)           DEFAULT 0 COMMENT '是/否已读',
    `creator`         varchar(64)          DEFAULT '' COMMENT '创建者',
    `create_time`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`         varchar(64) COMMENT '更新者',
    `update_time`     datetime(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`         bit(1)      NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`       bigint(20)  NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='客服消息';

CREATE TABLE `promotion_point_activity`
(
    `id`          bigint(20)                                                    NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `spu_id`      bigint(20)                                                    NOT NULL COMMENT 'spu编号',
    `status`      int(11)                                                                DEFAULT NULL COMMENT '活动状态',
    `remark`      varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL     DEFAULT NULL COMMENT '备注',
    `sort`        INT(11)                                                       NOT NULL COMMENT '排序',
    `stock`       int(11)                                                       NOT NULL DEFAULT 0 COMMENT '积分商城活动库存(剩余库存积分兑换时扣减)',
    `total_stock` int(11)                                                                DEFAULT NULL COMMENT '积分商城活动总库存',
    `creator`     varchar(64)                                                            DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0)                                                   NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)                                                        NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)                                                    NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='积分商城活动';

CREATE TABLE `promotion_point_product`
(
    `id`          bigint(20)     NOT NULL AUTO_INCREMENT COMMENT '编号，主键自增',
    `activity_id` bigint(20)              DEFAULT NULL COMMENT '积分商城活动',
    `spu_id`      bigint(20)     NOT NULL COMMENT 'spu编号',
    `sku_id`      bigint(20)              DEFAULT NULL COMMENT '商品 SKU 编号',
    `count`       int(11)                 DEFAULT NULL COMMENT '可兑换次数',
    `point`       INT(11)        NOT NULL COMMENT '所需兑换积分',
    `price`       decimal(19, 2) NOT NULL COMMENT '所需兑换金额，单位：分',
    `stock`       int(11)        NOT NULL DEFAULT 0 COMMENT '积分商城商品库存',
    `activity_status`     int(11)              DEFAULT NULL COMMENT '积分商城商品状态',
    `creator`     varchar(64)             DEFAULT '' COMMENT '创建者',
    `create_time` datetime(0)    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) COMMENT '创建时间',
    `updater`     varchar(64) COMMENT '更新者',
    `update_time` datetime(0)    NOT NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新时间',
    `deleted`     bit(1)         NOT NULL DEFAULT b'0' COMMENT '是否删除',
    `tenant_id`   bigint(20)     NOT NULL DEFAULT 0 COMMENT '租户编号',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4 COMMENT ='积分商城商品';