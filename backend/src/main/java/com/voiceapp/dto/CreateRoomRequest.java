package com.voiceapp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;

@Data
public class CreateRoomRequest {
    @NotBlank
    private String name;
    private String cover;
    private String category = "CHAT";
    @Min(10) @Max(500)
    private Integer maxUsers = 50;
    @Min(4) @Max(20)
    private Integer seatCount = 6;
}
