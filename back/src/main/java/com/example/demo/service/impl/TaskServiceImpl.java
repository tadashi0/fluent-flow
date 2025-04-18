package com.example.demo.service.impl;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.enums.PerformType;
import com.aizuda.bpm.engine.core.enums.TaskState;
import com.aizuda.bpm.engine.core.enums.TaskType;
import com.aizuda.bpm.engine.entity.FlwHisTask;
import com.aizuda.bpm.engine.entity.FlwHisTaskActor;
import com.aizuda.bpm.engine.entity.FlwTask;
import com.aizuda.bpm.engine.entity.FlwTaskActor;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisTaskActorMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisTaskMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwTaskActorMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwTaskMapper;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.Wrappers;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.example.demo.entity.AboutListVO;
import com.example.demo.entity.DoneListVO;
import com.example.demo.entity.SubmitListVO;
import com.example.demo.entity.TodoListVO;
import com.example.demo.mapper.TaskMapper;
import com.example.demo.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskServiceImpl implements TaskService {
    private final TaskMapper mapper;

    @Override
    public JSONObject taskCount() {
        // 获取当前用户
        String userId = "20240815";
        Map<String, Long> result = mapper.taskCount(userId, null);
        return new JSONObject(result);
    }

    @Override
    public IPage<TodoListVO> todoList(Page page) {
        // 获取当前用户
        String userId = "20240815";
        IPage<TodoListVO> pageResult = mapper.todoList(userId, null, page);
        return pageResult;
    }

    @Override
    public IPage<DoneListVO> doneList(Page page) {
        // 获取当前用户
        String userId = "20240815";
        IPage<DoneListVO> pageResult = mapper.doneList(userId, null, page);
        return pageResult;
    }

    @Override
    public IPage<SubmitListVO> submitList(Page page) {
        // 获取当前用户
        String userId = "20240815";
        IPage<SubmitListVO> pageResult = mapper.submitList(userId, null, page);
        return pageResult;
    }

    @Override
    public IPage<AboutListVO> aboutList(Page page) {
        // 获取当前用户
        String userId = "20240815";
        IPage<AboutListVO> pageResult = mapper.aboutList(userId, null, page);
        return pageResult;
    }
}
