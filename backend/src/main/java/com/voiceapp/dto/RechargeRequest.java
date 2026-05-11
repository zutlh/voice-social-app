package com.voiceapp.dto;

import lombok.Data;

@Data
public class RechargeRequest {
    private String receipt;
    private String planId;
}
