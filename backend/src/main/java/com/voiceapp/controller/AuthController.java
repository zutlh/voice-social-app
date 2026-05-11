package com.voiceapp.controller;

import com.voiceapp.common.ApiResult;
import com.voiceapp.dto.*;
import com.voiceapp.model.User;
import com.voiceapp.service.AuthService;
import com.voiceapp.service.SmsService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final SmsService smsService;
    private final AuthService authService;

    @PostMapping("/send-code")
    public ApiResult<Void> sendCode(@Valid @RequestBody SendCodeRequest request) {
        smsService.sendCode(request.getPhone());
        return ApiResult.success();
    }

    @PostMapping("/login")
    public ApiResult<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        return ApiResult.success(authService.login(request));
    }

    @PostMapping("/refresh-token")
    public ApiResult<LoginResponse> refreshToken(@Valid @RequestBody RefreshTokenRequest request) {
        return ApiResult.success(authService.refreshToken(request));
    }

    @GetMapping("/profile")
    public ApiResult<User> profile(@AuthenticationPrincipal Long userId) {
        return ApiResult.success(authService.getCurrentUser(userId));
    }

    @PutMapping("/profile")
    public ApiResult<Void> updateProfile(@AuthenticationPrincipal Long userId, @RequestBody User update) {
        update.setId(userId);
        authService.updateProfile(update);
        return ApiResult.success();
    }
}
