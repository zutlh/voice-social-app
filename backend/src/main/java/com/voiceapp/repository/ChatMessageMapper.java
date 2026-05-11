package com.voiceapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.voiceapp.model.ChatMessage;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChatMessageMapper extends BaseMapper<ChatMessage> {
}
