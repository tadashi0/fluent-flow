package com.example.demo.service;

import com.aizuda.bpm.engine.entity.FlwTask;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.demo.entity.AboutListVO;
import com.example.demo.entity.DoneListVO;
import com.example.demo.entity.SubmitListVO;
import com.example.demo.entity.TodoListVO;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description 
 */public interface TaskService {

    JSONObject taskCount();

    IPage<TodoListVO> todoList(Page page);

    IPage<DoneListVO> doneList(Page page);

    IPage<SubmitListVO> submitList(Page page);

    IPage<AboutListVO> aboutList(Page page);
}
