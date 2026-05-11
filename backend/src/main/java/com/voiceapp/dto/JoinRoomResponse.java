package com.voiceapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JoinRoomResponse {
    private Long roomId;
    private String channelName;
    private String agoraToken;
    private int agoraUid;
    private Integer seatCount;
}
