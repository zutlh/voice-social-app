package com.voiceapp.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.voiceapp.model.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}
