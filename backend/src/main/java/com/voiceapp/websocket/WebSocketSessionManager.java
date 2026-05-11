package com.voiceapp.websocket;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class WebSocketSessionManager {

    private final Map<String, SessionInfo> sessions = new ConcurrentHashMap<>();
    private final Map<String, WebSocketSession> wsSessions = new ConcurrentHashMap<>();
    private final Map<Long, Set<String>> roomSessions = new ConcurrentHashMap<>();

    public void register(String sessionId, Long userId, Long roomId, WebSocketSession wsSession) {
        sessions.put(sessionId, new SessionInfo(userId, roomId));
        wsSessions.put(sessionId, wsSession);
        roomSessions.computeIfAbsent(roomId, k -> ConcurrentHashMap.newKeySet()).add(sessionId);
    }

    public void remove(String sessionId) {
        SessionInfo info = sessions.remove(sessionId);
        wsSessions.remove(sessionId);
        if (info != null) {
            Set<String> set = roomSessions.get(info.roomId);
            if (set != null) {
                set.remove(sessionId);
                if (set.isEmpty()) roomSessions.remove(info.roomId);
            }
        }
    }

    public SessionInfo get(String sessionId) {
        return sessions.get(sessionId);
    }

    public WebSocketSession getSession(String sessionId) {
        return wsSessions.get(sessionId);
    }

    public Set<String> getRoomSessions(Long roomId) {
        return roomSessions.getOrDefault(roomId, Set.of());
    }

    public record SessionInfo(Long userId, Long roomId) {}
}
