package com.voiceapp.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("voice_room")
public class VoiceRoom {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long ownerId;
    private String name;
    private String cover;
    private String category;
    private Integer maxUsers;
    private Integer seatCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
