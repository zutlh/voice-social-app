CREATE TABLE `user` (
    `id` BIGINT NOT NULL PRIMARY KEY COMMENT '雪花ID',
    `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
    `nickname` VARCHAR(64) DEFAULT '' COMMENT '昵称',
    `avatar` VARCHAR(512) DEFAULT '' COMMENT '头像URL',
    `gender` VARCHAR(10) DEFAULT 'UNKNOWN' COMMENT '性别 MALE/FEMALE/UNKNOWN',
    `status` TINYINT DEFAULT 1 COMMENT '状态 1正常 0禁用',
    `refresh_token` VARCHAR(512) DEFAULT '' COMMENT '刷新Token',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

CREATE TABLE `voice_room` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `owner_id` BIGINT NOT NULL COMMENT '房主ID',
    `name` VARCHAR(128) NOT NULL COMMENT '房间名称',
    `cover` VARCHAR(512) DEFAULT '' COMMENT '封面URL',
    `category` VARCHAR(20) DEFAULT 'CHAT' COMMENT '分类 GAME/MUSIC/CHAT/OTHER',
    `max_users` INT DEFAULT 50 COMMENT '最大人数',
    `seat_count` INT DEFAULT 6 COMMENT '麦位数',
    `status` VARCHAR(10) DEFAULT 'OPEN' COMMENT '状态 OPEN/CLOSED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_category` (`category`),
    INDEX `idx_status` (`status`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='语音房间表';

CREATE TABLE `room_seat` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `room_id` BIGINT NOT NULL COMMENT '房间ID',
    `seat_index` INT NOT NULL COMMENT '麦位序号 0-based',
    `status` VARCHAR(10) DEFAULT 'FREE' COMMENT 'FREE/OCCUPIED/LOCKED',
    `user_id` BIGINT DEFAULT NULL COMMENT '占位用户ID',
    `mic_open` TINYINT DEFAULT 0 COMMENT '麦克风 0关闭 1开启',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_room_seat` (`room_id`, `seat_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='麦位表';

CREATE TABLE `gift` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(64) NOT NULL COMMENT '礼物名称',
    `icon` VARCHAR(512) DEFAULT '' COMMENT '图标URL',
    `price` INT NOT NULL COMMENT '金币价格',
    `type` VARCHAR(20) DEFAULT 'NORMAL' COMMENT '类型 NORMAL/EFFECT/LUXURY',
    `sort_order` INT DEFAULT 0 COMMENT '排序',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='礼物定义表';

CREATE TABLE `gift_record` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `from_uid` BIGINT NOT NULL COMMENT '赠送者',
    `to_uid` BIGINT NOT NULL COMMENT '接收者',
    `gift_id` BIGINT NOT NULL COMMENT '礼物ID',
    `quantity` INT DEFAULT 1 COMMENT '数量',
    `room_id` BIGINT DEFAULT NULL COMMENT '房间ID',
    `total_coins` INT NOT NULL COMMENT '总消耗金币',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_from` (`from_uid`, `created_at`),
    INDEX `idx_to` (`to_uid`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='送礼记录表';

CREATE TABLE `recharge_order` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `amount_yuan` DECIMAL(10,2) NOT NULL COMMENT '支付金额(元)',
    `coins` INT NOT NULL COMMENT '获得金币',
    `apple_trans_id` VARCHAR(256) DEFAULT '' COMMENT '苹果交易ID',
    `status` VARCHAR(20) DEFAULT 'PENDING' COMMENT 'PENDING/SUCCESS/FAILED',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_user` (`user_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='充值订单表';

CREATE TABLE `user_coin_account` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `balance` INT DEFAULT 0 COMMENT '金币余额',
    `total_recharged` INT DEFAULT 0 COMMENT '累计充值',
    `total_spent` INT DEFAULT 0 COMMENT '累计消费',
    `version` INT DEFAULT 0 COMMENT '乐观锁版本号',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户金币账户表';

CREATE TABLE `chat_message` (
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `room_id` BIGINT NOT NULL COMMENT '房间ID',
    `user_id` BIGINT NOT NULL COMMENT '发送者ID',
    `content` VARCHAR(1024) NOT NULL COMMENT '消息内容',
    `type` VARCHAR(10) DEFAULT 'TEXT' COMMENT 'TEXT/SYSTEM/GIFT',
    `created_at` DATETIME(3) DEFAULT CURRENT_TIMESTAMP(3),
    INDEX `idx_room_time` (`room_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='聊天消息表';
