package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import com.voiceapp.common.JwtUtil;
import com.voiceapp.dto.LoginRequest;
import com.voiceapp.dto.LoginResponse;
import com.voiceapp.dto.RefreshTokenRequest;
import com.voiceapp.model.User;
import com.voiceapp.repository.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final SmsService smsService;
    private final JwtUtil jwtUtil;

    @Transactional
    public LoginResponse login(LoginRequest request) {
        if (!smsService.verifyCode(request.getPhone(), request.getCode())) {
            throw new BizException(ErrorCode.VERIFY_CODE_ERROR);
        }

        User user = userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getPhone, request.getPhone()));

        if (user == null) {
            user = new User();
            user.setPhone(request.getPhone());
            user.setNickname("用户" + request.getPhone().substring(7));
            userMapper.insert(user);
        }

        String accessToken = jwtUtil.generateAccessToken(user.getId());
        String refreshToken = jwtUtil.generateRefreshToken(user.getId());

        user.setRefreshToken(refreshToken);
        userMapper.updateById(user);

        return new LoginResponse(user.getId(), accessToken, refreshToken, 900);
    }

    public LoginResponse refreshToken(RefreshTokenRequest request) {
        if (!jwtUtil.validateToken(request.getRefreshToken())) {
            throw new BizException(ErrorCode.UNAUTHORIZED);
        }

        Long userId = jwtUtil.getUserId(request.getRefreshToken());

        User user = userMapper.selectById(userId);
        if (user == null || !request.getRefreshToken().equals(user.getRefreshToken())) {
            throw new BizException(ErrorCode.UNAUTHORIZED);
        }

        String newAccessToken = jwtUtil.generateAccessToken(userId);
        String newRefreshToken = jwtUtil.generateRefreshToken(userId);

        user.setRefreshToken(newRefreshToken);
        userMapper.updateById(user);

        return new LoginResponse(userId, newAccessToken, newRefreshToken, 900);
    }

    public User getCurrentUser(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new BizException(ErrorCode.USER_NOT_FOUND);
        }
        return user;
    }

    public void updateProfile(User update) {
        User user = userMapper.selectById(update.getId());
        if (user == null) {
            throw new BizException(ErrorCode.USER_NOT_FOUND);
        }
        if (update.getNickname() != null) user.setNickname(update.getNickname());
        if (update.getAvatar() != null) user.setAvatar(update.getAvatar());
        if (update.getGender() != null) user.setGender(update.getGender());
        userMapper.updateById(user);
    }
}
