ALTER TABLE `user_info`
    ADD COLUMN `is_deleted` tinyint(1) NOT NULL DEFAULT 0 AFTER `updated_at`;
