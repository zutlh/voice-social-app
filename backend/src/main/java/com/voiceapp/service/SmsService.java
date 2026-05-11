package com.voiceapp.service;

import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Random;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class SmsService {

    private final StringRedisTemplate redisTemplate;
    private static final String CODE_PREFIX = "sms:code:";
    private static final String RATE_PREFIX = "sms:rate:";
    private static final int CODE_TTL = 5;
    private static final int RATE_TTL = 60;

    public void sendCode(String phone) {
        String rateKey = RATE_PREFIX + phone;
        if (Boolean.TRUE.equals(redisTemplate.hasKey(rateKey))) {
            throw new BizException(ErrorCode.VERIFY_CODE_TOO_FREQUENT);
        }

        String code = String.format("%06d", new Random().nextInt(1000000));
        String codeKey = CODE_PREFIX + phone;

        redisTemplate.opsForValue().set(codeKey, code, CODE_TTL, TimeUnit.MINUTES);
        redisTemplate.opsForValue().set(rateKey, "1", RATE_TTL, TimeUnit.SECONDS);

        log.info("验证码发送: phone={}, code={}", phone, code);
    }

    public boolean verifyCode(String phone, String code) {
        String codeKey = CODE_PREFIX + phone;
        String saved = redisTemplate.opsForValue().get(codeKey);
        if (saved == null || !saved.equals(code)) {
            return false;
        }
        redisTemplate.delete(codeKey);
        return true;
    }
}
