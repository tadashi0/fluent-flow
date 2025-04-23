package com.wf.service;

import com.alibaba.fastjson2.JSONObject;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.AboutListVO;
import com.wf.entity.DoneListVO;
import com.wf.entity.SubmitListVO;
import com.wf.entity.TodoListVO;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description 
 */public interface TaskService {

    JSONObject taskCount();

    IPage<TodoListVO> todoList(Page page);

    IPage<DoneListVO> doneList(Page page);

    IPage<SubmitListVO> submitList(boolean isAll, Page page);

    IPage<AboutListVO> aboutList(Page page);
}
