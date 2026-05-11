package com.voiceapp.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("gift_record")
public class GiftRecord {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long fromUid;
    private Long toUid;
    private Long giftId;
    private Integer quantity;
    private Long roomId;
    private Integer totalCoins;
    private LocalDateTime createdAt;
}
