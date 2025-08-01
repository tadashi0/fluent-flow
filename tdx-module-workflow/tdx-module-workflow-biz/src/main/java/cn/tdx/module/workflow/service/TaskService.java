package cn.tdx.module.workflow.service;

import cn.tdx.module.workflow.dal.AboutListVO;
import cn.tdx.module.workflow.dal.DoneListVO;
import cn.tdx.module.workflow.dal.SubmitListVO;
import cn.tdx.module.workflow.dal.TodoListVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

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
