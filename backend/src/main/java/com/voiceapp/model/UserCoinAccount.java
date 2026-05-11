package com.voiceapp.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.Version;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("user_coin_account")
public class UserCoinAccount {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long userId;
    private Integer balance;
    private Integer totalRecharged;
    private Integer totalSpent;
    @Version
    private Integer version;
    private LocalDateTime updatedAt;
}
