package com.voiceapp.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.voiceapp.common.ApiResult;
import com.voiceapp.dto.*;
import com.voiceapp.service.RoomService;
import com.voiceapp.service.SeatService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("/api/v1/rooms")
@RequiredArgsConstructor
public class RoomController {

    private final RoomService roomService;
    private final SeatService seatService;

    @PostMapping
    public ApiResult<RoomResponse> create(@AuthenticationPrincipal Long userId,
                                          @Valid @RequestBody CreateRoomRequest request) {
        return ApiResult.success(roomService.createRoom(userId, request));
    }

    @GetMapping
    public ApiResult<Page<RoomResponse>> list(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String category) {
        return ApiResult.success(roomService.listRooms(page, size, category));
    }

    @PostMapping("/{id}/join")
    public ApiResult<JoinRoomResponse> join(@AuthenticationPrincipal Long userId, @PathVariable Long id) {
        return ApiResult.success(roomService.joinRoom(userId, id));
    }

    @PostMapping("/{id}/leave")
    public ApiResult<Void> leave(@AuthenticationPrincipal Long userId, @PathVariable Long id) {
        roomService.leaveRoom(userId, id);
        return ApiResult.success();
    }

    @DeleteMapping("/{id}")
    public ApiResult<Void> close(@AuthenticationPrincipal Long userId, @PathVariable Long id) {
        roomService.closeRoom(userId, id);
        return ApiResult.success();
    }

    @GetMapping("/{id}/seats")
    public ApiResult<List<SeatInfo>> seats(@PathVariable Long id) {
        return ApiResult.success(roomService.getSeats(id));
    }

    @GetMapping("/{id}/users")
    public ApiResult<Set<Object>> onlineUsers(@PathVariable Long id) {
        return ApiResult.success(roomService.getOnlineUsers(id));
    }

    @PostMapping("/{id}/seats/{seatIndex}/apply")
    public ApiResult<Void> applySeat(@AuthenticationPrincipal Long userId,
                                     @PathVariable Long id, @PathVariable int seatIndex) {
        seatService.applySeat(userId, id, seatIndex);
        return ApiResult.success();
    }

    @PostMapping("/{id}/seats/release")
    public ApiResult<Void> releaseSeat(@AuthenticationPrincipal Long userId, @PathVariable Long id) {
        seatService.releaseSeat(userId, id);
        return ApiResult.success();
    }

    @PostMapping("/{id}/seats/{seatIndex}/lock")
    public ApiResult<Void> lockSeat(@PathVariable Long id, @PathVariable int seatIndex,
                                    @RequestParam boolean locked) {
        seatService.lockSeat(id, seatIndex, locked);
        return ApiResult.success();
    }
}
