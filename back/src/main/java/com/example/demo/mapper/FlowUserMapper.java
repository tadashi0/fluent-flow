package com.example.demo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.example.demo.entity.FlowUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * The MyBatis mapper of table 'flow_user'
 *
 * @author chonghui.tian
 * @since 2025-04-22
 */
@Mapper
public interface FlowUserMapper extends BaseMapper<FlowUser> {

}
