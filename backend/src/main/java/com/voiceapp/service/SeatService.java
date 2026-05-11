package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import com.voiceapp.model.RoomSeat;
import com.voiceapp.repository.RoomSeatMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class SeatService {

    private final RoomSeatMapper seatMapper;

    @Transactional
    public void applySeat(Long userId, Long roomId, int seatIndex) {
        // 先释放该用户已占的其他麦位（一人只能上一个麦）
        RoomSeat existing = seatMapper.selectOne(
                new LambdaQueryWrapper<RoomSeat>()
                        .eq(RoomSeat::getRoomId, roomId)
                        .eq(RoomSeat::getUserId, userId));
        if (existing != null) {
            existing.setStatus("FREE");
            existing.setUserId(null);
            existing.setMicOpen(0);
            seatMapper.updateById(existing);
        }

        RoomSeat seat = seatMapper.selectOne(
                new LambdaQueryWrapper<RoomSeat>()
                        .eq(RoomSeat::getRoomId, roomId)
                        .eq(RoomSeat::getSeatIndex, seatIndex));

        if (seat == null) throw new BizException(ErrorCode.ROOM_NOT_FOUND);
        if ("LOCKED".equals(seat.getStatus())) throw new BizException(ErrorCode.SEAT_LOCKED);
        if ("OCCUPIED".equals(seat.getStatus())) throw new BizException(ErrorCode.SEAT_OCCUPIED);

        seat.setStatus("OCCUPIED");
        seat.setUserId(userId);
        seat.setMicOpen(1);
        seatMapper.updateById(seat);
    }

    @Transactional
    public void releaseSeat(Long userId, Long roomId) {
        RoomSeat seat = seatMapper.selectOne(
                new LambdaQueryWrapper<RoomSeat>()
                        .eq(RoomSeat::getRoomId, roomId)
                        .eq(RoomSeat::getUserId, userId));

        if (seat == null) return;

        seat.setStatus("FREE");
        seat.setUserId(null);
        seat.setMicOpen(0);
        seatMapper.updateById(seat);
    }

    @Transactional
    public void toggleMic(Long userId, Long roomId, boolean muted) {
        RoomSeat seat = seatMapper.selectOne(
                new LambdaQueryWrapper<RoomSeat>()
                        .eq(RoomSeat::getRoomId, roomId)
                        .eq(RoomSeat::getUserId, userId));

        if (seat == null) throw new BizException(ErrorCode.NOT_IN_ROOM);
        seat.setMicOpen(muted ? 0 : 1);
        seatMapper.updateById(seat);
    }

    @Transactional
    public void lockSeat(Long roomId, int seatIndex, boolean locked) {
        RoomSeat seat = seatMapper.selectOne(
                new LambdaQueryWrapper<RoomSeat>()
                        .eq(RoomSeat::getRoomId, roomId)
                        .eq(RoomSeat::getSeatIndex, seatIndex));

        if (seat == null) throw new BizException(ErrorCode.ROOM_NOT_FOUND);
        seat.setStatus(locked ? "LOCKED" : "FREE");
        if (locked) {
            seat.setUserId(null);
            seat.setMicOpen(0);
        }
        seatMapper.updateById(seat);
    }
}
