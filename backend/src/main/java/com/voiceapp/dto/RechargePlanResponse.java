package com.voiceapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RechargePlanResponse {
    private String planId;
    private Integer amountYuan;
    private Integer coins;
    private Integer bonus;
    private String appleProductId;
}
