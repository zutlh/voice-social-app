package com.voiceapp.dto;

import lombok.Data;

@Data
public class SeatInfo {
    private Integer index;
    private String status;
    private Long userId;
    private String userName;
    private String userAvatar;
    private Boolean micOpen;
}
