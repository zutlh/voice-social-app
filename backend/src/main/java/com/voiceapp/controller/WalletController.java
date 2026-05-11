package com.voiceapp.controller;

import com.voiceapp.common.ApiResult;
import com.voiceapp.dto.WalletResponse;
import com.voiceapp.service.WalletService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class WalletController {

    private final WalletService walletService;

    @GetMapping("/wallet")
    public ApiResult<WalletResponse> wallet(@AuthenticationPrincipal Long userId) {
        return ApiResult.success(walletService.getWallet(userId));
    }
}
