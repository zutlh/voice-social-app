package com.voiceapp.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class RoomResponse {
    private Long id;
    private Long ownerId;
    private String ownerName;
    private String ownerAvatar;
    private String name;
    private String cover;
    private String category;
    private Integer maxUsers;
    private Integer seatCount;
    private Integer onlineCount;
    private String status;
    private LocalDateTime createdAt;
}
