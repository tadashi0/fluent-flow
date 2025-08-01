package cn.tdx.module.workflow.service.impl;

import cn.tdx.framework.security.core.util.SecurityFrameworkUtils;
import cn.tdx.module.system.api.user.AdminUserApi;
import cn.tdx.module.system.api.user.dto.AdminUserRespDTO;
import cn.tdx.module.workflow.dal.AboutListVO;
import cn.tdx.module.workflow.dal.DoneListVO;
import cn.tdx.module.workflow.dal.SubmitListVO;
import cn.tdx.module.workflow.dal.TodoListVO;
import cn.tdx.module.workflow.mapper.TaskMapper;
import cn.tdx.module.workflow.service.TaskService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.sshd.common.util.security.SecurityUtils;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
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
    private final TaskMapper mapper;
    private final RedisService redisService;
    private final AdminUserApi adminUserApi;

    @Override
    public Long todoCount() {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        return mapper.todoCount(userId, null);
    }

    @Override
    public Long doneCount() {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        return redisService.getZSetScore("wf:count:done", userId);
        //return mapper.doneCount(userId, null);
    }

    @Override
    public Long submitCount() {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        return redisService.getZSetScore("wf:count:submit", userId);
        //return mapper.submitCount(userId, null);
    }
    
    @Override
    public Long aboutCount() {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        return redisService.getZSetScore("wf:count:about", userId);
        //return mapper.aboutCount(userId, null);
    }

    @Override
    public IPage<TodoListVO> todoList(Page page) {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        IPage<TodoListVO> pageResult = mapper.todoList(userId, null, page);
        return pageResult;
    }

    @Override
    public IPage<DoneListVO> doneList(Page page) {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        page.setSearchCount(false);
        IPage<DoneListVO> pageResult = mapper.doneList(userId, null, page);
        pageResult.setTotal(redisService.getZSetScore("wf:count:done", userId));
        return pageResult;
    }

    @Override
    public IPage<SubmitListVO> submitList(boolean isAll, Page page) {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        Set<Long> userIds = new HashSet<>();
        userIds.add(userId);
        page.setSearchCount(false);
        if(isAll) {
            userIds.addAll(adminUserApi.getUserListBySubordinate(userId)
                    .parallelStream()
                    .map(AdminUserRespDTO::getId)
                    .collect(Collectors.toSet()));
        }
        IPage<SubmitListVO> pageResult = mapper.submitList(userIds, null, page);
        pageResult.setTotal(redisService.getZSetScore("wf:count:submit", userId));
        return pageResult;
    }

    @Override
    public IPage<AboutListVO> aboutList(Page page) {
        // 获取当前用户
        Long userId = SecurityFrameworkUtils.getLoginUserId();
        page.setSearchCount(false);
        IPage<AboutListVO> pageResult = mapper.aboutList(userId, null, page);
        pageResult.setTotal(redisService.getZSetScore("wf:count:about", userId));
        return pageResult;
    }

}
