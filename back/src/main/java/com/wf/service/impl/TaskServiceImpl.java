package com.wf.service.impl;

import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.AboutListVO;
import com.wf.entity.DoneListVO;
import com.wf.entity.SubmitListVO;
import com.wf.entity.TodoListVO;
import com.wf.mapper.TaskMapper;
import com.wf.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

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
    public IPage<SubmitListVO> submitList(boolean isAll, Page page) {
        // 获取当前用户
        String userId = "20240815";
        IPage<SubmitListVO> pageResult = mapper.submitList(isAll ? null : userId, null, page);
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
