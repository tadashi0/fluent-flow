/*
 Navicat Premium Data Transfer

 Source Server         : 172.16.1.63
 Source Server Type    : MySQL
 Source Server Version : 50743 (5.7.43)
 Source Host           : 172.16.1.63:3306
 Source Schema         : am_flyway_demo

 Target Server Type    : MySQL
 Target Server Version : 50743 (5.7.43)
 File Encoding         : 65001

 Date: 16/04/2024 09:50:48
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for user_info_bak
-- ----------------------------
DROP TABLE IF EXISTS `user_info_bak`;
CREATE TABLE `user_info_bak` (
                             `user_id` int(11) NOT NULL AUTO_INCREMENT,
                             `username` varchar(50) NOT NULL,
                             `email` varchar(100) DEFAULT NULL,
                             `password` varchar(100) NOT NULL,
                             `full_name` varchar(100) DEFAULT NULL,
                             `birth_date` date DEFAULT NULL,
                             `address` varchar(255) DEFAULT NULL,
                             `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
