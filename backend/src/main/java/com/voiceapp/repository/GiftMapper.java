package com.voiceapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.voiceapp.model.Gift;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface GiftMapper extends BaseMapper<Gift> {
}
