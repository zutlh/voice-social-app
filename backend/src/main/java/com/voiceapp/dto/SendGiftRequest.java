package com.voiceapp.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SendGiftRequest {
    @NotNull
    private Long giftId;
    @NotNull
    private Long toUid;
    private Long roomId;
    @Min(1)
    private Integer quantity = 1;
}
