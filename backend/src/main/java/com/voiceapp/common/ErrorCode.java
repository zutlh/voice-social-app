package com.voiceapp.common;

import lombok.Getter;

@Getter
public enum ErrorCode {
    SUCCESS(200, "success"),

    PARAM_ERROR(1001, "参数错误"),
    UNAUTHORIZED(1002, "未登录或登录已过期"),
    FORBIDDEN(1003, "无权限"),
    RATE_LIMITED(1004, "请求过于频繁"),
    INTERNAL_ERROR(1005, "服务器内部错误"),

    VERIFY_CODE_ERROR(2001, "验证码错误或已过期"),
    VERIFY_CODE_TOO_FREQUENT(2002, "验证码发送过于频繁"),
    PHONE_ALREADY_EXISTS(2003, "手机号已注册"),
    USER_NOT_FOUND(2004, "用户不存在"),

    ROOM_NOT_FOUND(3001, "房间不存在"),
    SEAT_LOCKED(3002, "麦位已锁定"),
    SEAT_OCCUPIED(3003, "麦位已被占用"),
    NOT_IN_ROOM(3004, "不在房间内"),
    NOT_ROOM_OWNER(3005, "不是房主"),
    ROOM_FULL(3006, "房间已满"),

    INSUFFICIENT_COINS(4001, "金币余额不足"),
    GIFT_NOT_FOUND(4002, "礼物不存在"),
    RECHARGE_FAILED(4003, "充值失败"),

    WS_DISCONNECTED(5001, "连接断开"),
    WS_HEARTBEAT_TIMEOUT(5002, "心跳超时");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }
}
