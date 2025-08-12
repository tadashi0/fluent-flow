package cn.tdx.module.workflow.service.impl;

import cn.tdx.framework.security.core.LoginUser;
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
import org.springframework.stereotype.Service;

import java.util.HashSet;
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
        LoginUser loginUser = SecurityFrameworkUtils.getLoginUser();
        return mapper.todoCount(loginUser.getId(), loginUser.getTenantId());
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
        LoginUser loginUser = SecurityFrameworkUtils.getLoginUser();
        IPage<TodoListVO> pageResult = mapper.todoList(loginUser.getId(), loginUser.getTenantId(), page);
        return pageResult;
    }

    @Override
    public IPage<DoneListVO> doneList(Page page) {
        // 获取当前用户
        LoginUser loginUser = SecurityFrameworkUtils.getLoginUser();
        page.setSearchCount(false);
        IPage<DoneListVO> pageResult = mapper.doneList(loginUser.getId(), loginUser.getTenantId(), page);
        pageResult.setTotal(redisService.getZSetScore("wf:count:done", loginUser.getId()));
        return pageResult;
    }

    @Override
    public IPage<SubmitListVO> submitList(boolean isAll, Page page) {
        // 获取当前用户
        LoginUser loginUser = SecurityFrameworkUtils.getLoginUser();
        Set<Long> userIds = new HashSet<>();
        userIds.add(loginUser.getId());
        page.setSearchCount(false);
        if (isAll) {
            userIds.addAll(adminUserApi.getUserListBySubordinate(loginUser.getId())
                    .parallelStream()
                    .map(AdminUserRespDTO::getId)
                    .collect(Collectors.toSet()));
        }
        IPage<SubmitListVO> pageResult = mapper.submitList(userIds, loginUser.getTenantId(), page);
        pageResult.setTotal(userIds.stream()
                .map(e -> redisService.getZSetScore("wf:count:submit", e))
                .reduce(0L, Long::sum));
        return pageResult;
    }

    @Override
    public IPage<AboutListVO> aboutList(Page page) {
        // 获取当前用户
        LoginUser loginUser = SecurityFrameworkUtils.getLoginUser();
        page.setSearchCount(false);
        IPage<AboutListVO> pageResult = mapper.aboutList(loginUser.getId(), loginUser.getTenantId(), page);
        pageResult.setTotal(redisService.getZSetScore("wf:count:about", loginUser.getId()));
        return pageResult;
    }

}
