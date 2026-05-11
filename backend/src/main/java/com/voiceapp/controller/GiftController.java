package com.voiceapp.controller;

import com.voiceapp.common.ApiResult;
import com.voiceapp.dto.GiftResponse;
import com.voiceapp.dto.SendGiftRequest;
import com.voiceapp.service.GiftService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/gifts")
@RequiredArgsConstructor
public class GiftController {

    private final GiftService giftService;

    @GetMapping
    public ApiResult<List<GiftResponse>> list() {
        return ApiResult.success(giftService.listGifts());
    }

    @PostMapping("/send")
    public ApiResult<Void> send(@AuthenticationPrincipal Long userId,
                                @Valid @RequestBody SendGiftRequest request) {
        giftService.sendGift(userId, request);
        return ApiResult.success();
    }
}
