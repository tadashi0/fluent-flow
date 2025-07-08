package com.wf.service.wf;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.wf.AboutListVO;
import com.wf.entity.wf.DoneListVO;
import com.wf.entity.wf.SubmitListVO;
import com.wf.entity.wf.TodoListVO;

/**
 * @author chonghui. tian
 *         date 2025/4/17 17:26
 *         description
 */
public interface TaskService {

    Long todoCount();

    Long doneCount();

    Long submitCount();

    Long aboutCount();

    IPage<TodoListVO> todoList(Page page);

    IPage<DoneListVO> doneList(Page page);

    IPage<SubmitListVO> submitList(boolean isAll, Page page);

    IPage<AboutListVO> aboutList(Page page);
}
