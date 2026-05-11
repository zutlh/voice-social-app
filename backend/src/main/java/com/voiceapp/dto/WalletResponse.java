package com.voiceapp.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class WalletResponse {
    private Integer balance;
    private Integer totalRecharged;
    private Integer totalSpent;
}
