package com.voiceapp.model;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("room_seat")
public class RoomSeat {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long roomId;
    private Integer seatIndex;
    private String status;
    private Long userId;
    private Integer micOpen;
    private LocalDateTime updatedAt;
}
