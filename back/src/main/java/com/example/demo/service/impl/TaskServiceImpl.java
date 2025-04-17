package com.example.demo.service.impl;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.enums.TaskType;
import com.aizuda.bpm.engine.entity.FlwHisTask;
import com.aizuda.bpm.engine.entity.FlwHisTaskActor;
import com.aizuda.bpm.engine.entity.FlwTask;
import com.aizuda.bpm.engine.entity.FlwTaskActor;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisTaskActorMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwHisTaskMapper;
import com.aizuda.bpm.mybatisplus.mapper.FlwTaskActorMapper;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.example.demo.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TaskServiceImpl implements TaskService {
    private final FlowLongEngine flowLongEngine;
    private final FlwHisTaskMapper hisTaskMapper;
    private final FlwTaskActorMapper taskActorMapper;
    private final FlwHisTaskActorMapper hisTaskActorMapper;

    @Override
    public JSONObject getTaskCount() {
        // 获取当前用户
        String userId = "20240815";

        List<FlwHisTask> hisTaskList = ChainWrappers.lambdaQueryChain(hisTaskMapper)
                .select(FlwHisTask::getId, FlwHisTask::getTaskType)
                .list();

        Map<Integer, List<Long>> hisTaskMap = hisTaskList.stream()
                .collect(Collectors.groupingBy(FlwHisTask::getTaskType,
                        Collectors.mapping(FlwHisTask::getId, Collectors.toList())));

        Long todoCount = ChainWrappers.lambdaQueryChain(taskActorMapper)
                .eq(FlwTaskActor::getActorId, userId)
                .count();

        Long doneCount = ChainWrappers.lambdaQueryChain(hisTaskActorMapper)
                        .in(FlwHisTaskActor::getTaskId, hisTaskMap.get(TaskType.approval))
                        .eq(FlwTaskActor::getActorId, userId)
                        .count();

        Long submitCount = ChainWrappers.lambdaQueryChain(hisTaskActorMapper)
                .in(FlwHisTaskActor::getTaskId, hisTaskMap.get(TaskType.major))
                .eq(FlwTaskActor::getActorId, userId)
                .count();

        Long aboutCount = ChainWrappers.lambdaQueryChain(hisTaskActorMapper)
                .in(FlwHisTaskActor::getTaskId, hisTaskMap.get(TaskType.cc))
                .eq(FlwTaskActor::getActorId, userId)
                .count();

        return new JSONObject() {{
            put("todo", todoCount);
            put("done", doneCount);
            put("submit", submitCount);
            put("about", aboutCount);
        }};
    }

    @Override
    public IPage<FlwTask> todoList(Page page) {
        // 获取当前用户
        String userId = "20240815";

        IPage<FlwTaskActor> pareResult = ChainWrappers.lambdaQueryChain(taskActorMapper)
                .eq(FlwTaskActor::getActorId, userId)
                .page(page);
        return null;
    }
}
