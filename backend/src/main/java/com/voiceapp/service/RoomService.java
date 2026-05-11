package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import com.voiceapp.dto.*;
import com.voiceapp.model.RoomSeat;
import com.voiceapp.model.User;
import com.voiceapp.model.VoiceRoom;
import com.voiceapp.repository.RoomSeatMapper;
import com.voiceapp.repository.UserMapper;
import com.voiceapp.repository.VoiceRoomMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
public class RoomService {

    private final VoiceRoomMapper roomMapper;
    private final RoomSeatMapper seatMapper;
    private final UserMapper userMapper;
    private final AgoraTokenService agoraTokenService;
    private final RedisTemplate<String, Object> redisTemplate;

    private static final String ROOM_ONLINE_KEY = "room:online:";

    @Transactional
    public RoomResponse createRoom(Long ownerId, CreateRoomRequest request) {
        VoiceRoom room = new VoiceRoom();
        room.setOwnerId(ownerId);
        room.setName(request.getName());
        room.setCover(request.getCover());
        room.setCategory(request.getCategory());
        room.setMaxUsers(request.getMaxUsers());
        room.setSeatCount(request.getSeatCount());
        roomMapper.insert(room);

        for (int i = 0; i < request.getSeatCount(); i++) {
            RoomSeat seat = new RoomSeat();
            seat.setRoomId(room.getId());
            seat.setSeatIndex(i);
            seatMapper.insert(seat);
        }

        return buildResponse(room);
    }

    public Page<RoomResponse> listRooms(int page, int size, String category) {
        LambdaQueryWrapper<VoiceRoom> qw = new LambdaQueryWrapper<VoiceRoom>()
                .eq(VoiceRoom::getStatus, "OPEN");
        if (category != null && !category.isEmpty()) {
            qw.eq(VoiceRoom::getCategory, category);
        }
        qw.orderByDesc(VoiceRoom::getCreatedAt);

        Page<VoiceRoom> result = roomMapper.selectPage(new Page<>(page, size), qw);
        Page<RoomResponse> response = new Page<>(page, size, result.getTotal());
        List<RoomResponse> list = new ArrayList<>();
        for (VoiceRoom room : result.getRecords()) {
            User owner = userMapper.selectById(room.getOwnerId());
            RoomResponse r = buildResponse(room);
            r.setOwnerName(owner != null ? owner.getNickname() : "");
            r.setOwnerAvatar(owner != null ? owner.getAvatar() : "");

            Long count = redisTemplate.opsForSet().size(ROOM_ONLINE_KEY + room.getId());
            r.setOnlineCount(count != null ? count.intValue() : 0);
            list.add(r);
        }
        response.setRecords(list);
        return response;
    }

    public JoinRoomResponse joinRoom(Long userId, Long roomId) {
        VoiceRoom room = roomMapper.selectById(roomId);
        if (room == null || !"OPEN".equals(room.getStatus())) {
            throw new BizException(ErrorCode.ROOM_NOT_FOUND);
        }

        Long count = redisTemplate.opsForSet().size(ROOM_ONLINE_KEY + roomId);
        if (count != null && count >= room.getMaxUsers()) {
            throw new BizException(ErrorCode.ROOM_FULL);
        }

        redisTemplate.opsForSet().add(ROOM_ONLINE_KEY + roomId, userId.toString());

        String channelName = "room_" + roomId;
        String token = agoraTokenService.generateToken(channelName, userId.intValue());
        return new JoinRoomResponse(roomId, channelName, token, userId.intValue(), room.getSeatCount());
    }

    public void leaveRoom(Long userId, Long roomId) {
        redisTemplate.opsForSet().remove(ROOM_ONLINE_KEY + roomId, userId.toString());
    }

    @Transactional
    public void closeRoom(Long ownerId, Long roomId) {
        VoiceRoom room = roomMapper.selectById(roomId);
        if (room == null || !room.getOwnerId().equals(ownerId)) {
            throw new BizException(ErrorCode.NOT_ROOM_OWNER);
        }
        room.setStatus("CLOSED");
        roomMapper.updateById(room);
        redisTemplate.delete(ROOM_ONLINE_KEY + roomId);
    }

    public List<SeatInfo> getSeats(Long roomId) {
        List<RoomSeat> seats = seatMapper.selectList(
                new LambdaQueryWrapper<RoomSeat>().eq(RoomSeat::getRoomId, roomId).orderByAsc(RoomSeat::getSeatIndex));
        List<SeatInfo> result = new ArrayList<>();
        for (RoomSeat seat : seats) {
            SeatInfo info = new SeatInfo();
            info.setIndex(seat.getSeatIndex());
            info.setStatus(seat.getStatus());
            info.setMicOpen(seat.getMicOpen() != null && seat.getMicOpen() == 1);
            if (seat.getUserId() != null) {
                info.setUserId(seat.getUserId());
                User u = userMapper.selectById(seat.getUserId());
                if (u != null) {
                    info.setUserName(u.getNickname());
                    info.setUserAvatar(u.getAvatar());
                }
            }
            result.add(info);
        }
        return result;
    }

    public Set<Object> getOnlineUsers(Long roomId) {
        return redisTemplate.opsForSet().members(ROOM_ONLINE_KEY + roomId);
    }

    private RoomResponse buildResponse(VoiceRoom room) {
        RoomResponse r = new RoomResponse();
        r.setId(room.getId());
        r.setOwnerId(room.getOwnerId());
        r.setName(room.getName());
        r.setCover(room.getCover());
        r.setCategory(room.getCategory());
        r.setMaxUsers(room.getMaxUsers());
        r.setSeatCount(room.getSeatCount());
        r.setOnlineCount(0);
        r.setStatus(room.getStatus());
        r.setCreatedAt(room.getCreatedAt());
        return r;
    }
}
