ALTER TABLE `chonghui`.`flw_his_instance` 
ADD INDEX `idx_his_business_key`(`business_key`) USING HASH;

ALTER TABLE `chonghui`.`flw_task`
MODIFY COLUMN `remind_repeat` tinyint(3) NOT NULL DEFAULT 0 COMMENT '提醒次数' AFTER `remind_time`;