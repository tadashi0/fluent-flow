package com.wf.service.wf.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.wf.AboutListVO;
import com.wf.entity.wf.DoneListVO;
import com.wf.entity.wf.SubmitListVO;
import com.wf.entity.wf.TodoListVO;
import com.wf.mapper.wf.TaskMapper;
import com.wf.service.wf.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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
    public Long todoCount() {
        // 获取当前用户
        String userId = "20240815";
        return mapper.todoCount(userId, null);
    }

    @Override
    public Long doneCount() {
        // 获取当前用户
        String userId = "20240815";
        return mapper.doneCount(userId, null);
    }

    @Override
    public Long submitCount() {
        // 获取当前用户
        String userId = "20240815";


        return mapper.submitCount(userId, null);
    }
    
    @Override
    public Long aboutCount() {
        // 获取当前用户
        String userId = "20240815";
        return mapper.aboutCount(userId, null);
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
        page.setSearchCount(false);
        IPage<DoneListVO> pageResult = mapper.doneList(userId, null, page);
        pageResult.setTotal(1000000);
        return pageResult;
    }

    @Override
    public IPage<SubmitListVO> submitList(boolean isAll, Page page) {
        // 获取当前用户
        String userId = "20240815";
        page.setSearchCount(false);
        IPage<SubmitListVO> pageResult = mapper.submitList(isAll ? null : userId, null, page);
        pageResult.setTotal(200000);
        return pageResult;
    }

    @Override
    public IPage<AboutListVO> aboutList(Page page) {
        // 获取当前用户
        String userId = "20240815";
        page.setSearchCount(false);
        IPage<AboutListVO> pageResult = mapper.aboutList(userId, null, page);
        pageResult.setTotal(200000);
        return pageResult;
    }

}
