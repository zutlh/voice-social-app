package com.voiceapp.websocket;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.voiceapp.common.JwtUtil;
import com.voiceapp.service.SeatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.*;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class RoomWebSocketHandler extends TextWebSocketHandler {

    private final WebSocketSessionManager sessionManager;
    private final SeatService seatService;
    private final JwtUtil jwtUtil;
    private final ObjectMapper objectMapper;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        URI uri = session.getUri();
        if (uri == null) { closeSession(session); return; }

        Map<String, String> params = parseQuery(uri.getQuery());
        String token = params.get("token");
        String roomIdStr = params.get("roomId");

        if (token == null || roomIdStr == null || !jwtUtil.validateToken(token)) {
            closeSession(session); return;
        }

        Long userId = jwtUtil.getUserId(token);
        Long roomId = Long.parseLong(roomIdStr);
        sessionManager.register(session.getId(), userId, roomId);

        log.info("WS connected: userId={}, roomId={}", userId, roomId);

        broadcastToRoom(roomId, Map.of(
                "type", "USER_JOIN",
                "roomId", roomId,
                "data", Map.of("userId", userId),
                "timestamp", System.currentTimeMillis()
        ));
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        WebSocketSessionManager.SessionInfo info = sessionManager.get(session.getId());
        if (info == null) { closeSession(session); return; }

        Map<String, Object> msg = objectMapper.readValue(message.getPayload(), Map.class);
        String type = (String) msg.get("type");

        switch (type) {
            case "CHAT_SEND" -> {
                String content = msg.getOrDefault("data", Map.of()).toString();
                Map<String, Object> chatData = new HashMap<>();
                try {
                    Map<String, Object> dataMap = (Map<String, Object>) msg.get("data");
                    content = dataMap.getOrDefault("content", "").toString();
                } catch (Exception ignored) {}
                broadcastToRoom(info.roomId(), Map.of(
                        "type", "CHAT_MSG",
                        "roomId", info.roomId(),
                        "data", Map.of("userId", info.userId(), "content", content),
                        "timestamp", System.currentTimeMillis()
                ));
            }
            case "SEAT_APPLY" -> {
                int seatIndex = -1;
                try {
                    Map<String, Object> dataMap = (Map<String, Object>) msg.get("data");
                    if (dataMap != null && dataMap.get("seatIndex") != null) {
                        seatIndex = Integer.parseInt(dataMap.get("seatIndex").toString());
                    }
                } catch (Exception ignored) {}
                try {
                    seatService.applySeat(info.userId(), info.roomId(), seatIndex);
                } catch (Exception e) {
                    sendError(session, e.getMessage());
                }
                broadcastSeatUpdate(info.roomId());
            }
            case "SEAT_RELEASE" -> {
                try {
                    seatService.releaseSeat(info.userId(), info.roomId());
                } catch (Exception e) {
                    sendError(session, e.getMessage());
                }
                broadcastSeatUpdate(info.roomId());
            }
            case "SEAT_MUTE" -> {
                boolean muted = false;
                try {
                    Map<String, Object> dataMap = (Map<String, Object>) msg.get("data");
                    if (dataMap != null && dataMap.get("muted") != null) {
                        muted = Boolean.parseBoolean(dataMap.get("muted").toString());
                    }
                } catch (Exception ignored) {}
                seatService.toggleMic(info.userId(), info.roomId(), muted);
            }
            case "HEARTBEAT" -> sendHeartbeatAck(session);
            default -> log.warn("Unknown WS message type: {}", type);
        }
    }

    private void broadcastSeatUpdate(Long roomId) {
        broadcastToRoom(roomId, Map.of(
                "type", "SEAT_UPDATE",
                "roomId", roomId,
                "data", Map.of("updated", true),
                "timestamp", System.currentTimeMillis()
        ));
    }

    private void sendError(WebSocketSession session, String message) {
        try {
            String json = objectMapper.writeValueAsString(Map.of(
                    "type", "ERROR",
                    "data", Map.of("message", message),
                    "timestamp", System.currentTimeMillis()
            ));
            session.sendMessage(new TextMessage(json));
        } catch (IOException ignored) {}
    }

    private void sendHeartbeatAck(WebSocketSession session) {
        try {
            session.sendMessage(new TextMessage("{\"type\":\"HEARTBEAT_ACK\"}"));
        } catch (IOException e) {
            log.warn("心跳回复失败");
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
        WebSocketSessionManager.SessionInfo info = sessionManager.get(session.getId());
        if (info != null) {
            try {
                seatService.releaseSeat(info.userId(), info.roomId());
            } catch (Exception ignored) {}

            sessionManager.remove(session.getId());

            broadcastToRoom(info.roomId(), Map.of(
                    "type", "USER_LEAVE",
                    "roomId", info.roomId(),
                    "data", Map.of("userId", info.userId()),
                    "timestamp", System.currentTimeMillis()
            ));
            broadcastSeatUpdate(info.roomId());
        }
    }

    private void broadcastToRoom(Long roomId, Map<String, Object> message) {
        try {
            String json = objectMapper.writeValueAsString(message);
            TextMessage text = new TextMessage(json);
            for (String sid : sessionManager.getRoomSessions(roomId)) {
                // 在Redis Pub/Sub实现前，仅记录日志
            }
            log.debug("房间[{}]广播: {}", roomId, json);
        } catch (Exception e) {
            log.error("广播失败", e);
        }
    }

    private void closeSession(WebSocketSession session) {
        try { session.close(); } catch (Exception ignored) {}
    }

    private Map<String, String> parseQuery(String query) {
        Map<String, String> map = new HashMap<>();
        if (query != null) {
            for (String pair : query.split("&")) {
                String[] kv = pair.split("=", 2);
                if (kv.length == 2) map.put(kv[0], kv[1]);
            }
        }
        return map;
    }
}
