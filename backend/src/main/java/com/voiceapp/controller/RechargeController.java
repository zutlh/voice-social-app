package com.voiceapp.controller;

import com.voiceapp.common.ApiResult;
import com.voiceapp.dto.RechargePlanResponse;
import com.voiceapp.dto.RechargeRequest;
import com.voiceapp.model.RechargeOrder;
import com.voiceapp.service.RechargeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/recharge")
@RequiredArgsConstructor
public class RechargeController {

    private final RechargeService rechargeService;

    @GetMapping("/plans")
    public ApiResult<List<RechargePlanResponse>> plans() {
        return ApiResult.success(rechargeService.getPlans());
    }

    @PostMapping("/verify")
    public ApiResult<Void> verify(@AuthenticationPrincipal Long userId,
                                  @RequestBody RechargeRequest request) {
        rechargeService.verifyReceipt(userId, request.getReceipt());
        return ApiResult.success();
    }

    @PostMapping("/mock")
    public ApiResult<Void> mockRecharge(@AuthenticationPrincipal Long userId,
                                        @RequestBody RechargeRequest request) {
        rechargeService.mockRecharge(userId, request.getPlanId());
        return ApiResult.success();
    }

    @GetMapping("/orders")
    public ApiResult<List<RechargeOrder>> orders(@AuthenticationPrincipal Long userId) {
        return ApiResult.success(rechargeService.listOrders(userId));
    }
}
