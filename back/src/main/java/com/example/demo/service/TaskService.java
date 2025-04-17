package com.example.demo.service;

import com.aizuda.bpm.engine.entity.FlwTask;
import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description 
 */public interface TaskService {

    JSONObject getTaskCount();

    IPage<FlwTask> todoList(Page page);
}
