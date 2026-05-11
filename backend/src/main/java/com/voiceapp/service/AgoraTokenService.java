package com.voiceapp.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Service
public class AgoraTokenService {

    @Value("${agora.app-id}")
    private String appId;

    @Value("${agora.app-certificate}")
    private String appCertificate;

    @Value("${agora.token-expiration-seconds}")
    private int expirationSeconds;

    public String generateToken(String channelName, int uid) {
        long expireTime = System.currentTimeMillis() / 1000 + expirationSeconds;
        String raw = appId + ":" + channelName + ":" + uid + ":" + expireTime;
        if (appCertificate == null || appCertificate.isEmpty()) {
            return Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
        }
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(appCertificate.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] sign = mac.doFinal(raw.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8))
                    + "." + Base64.getEncoder().encodeToString(sign);
        } catch (Exception e) {
            return Base64.getEncoder().encodeToString(raw.getBytes(StandardCharsets.UTF_8));
        }
    }
}
