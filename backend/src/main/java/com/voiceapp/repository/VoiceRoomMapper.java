package com.voiceapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.voiceapp.model.VoiceRoom;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface VoiceRoomMapper extends BaseMapper<VoiceRoom> {
}
