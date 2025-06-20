package com.wf.service.wf.impl;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wf.common.exception.ServiceException;
import com.wf.entity.wf.FlowUser;
import com.wf.mapper.wf.FlowUserMapper;
import com.wf.mapper.wf.TaskMapper;
import com.wf.service.wf.FlowUserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * The implementation of {@link FlowUserService}.
 *
 * @author chonghui.tian
 * @since 2025-04-22
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class FlowUserServiceImpl extends ServiceImpl<FlowUserMapper, FlowUser> implements FlowUserService {

    private final FlowUserMapper flowUserMapper;
    private final TaskMapper taskMapper;

    /**
     * Create a FlowUser.
     *
     * @param flowUser A new FlowUser to create
     * @return The instance of {@code FlowUser} that was just created
     */
    @Override
    public Optional<FlowUser> createFlowUser(FlowUser flowUser) {
        flowUser.setCreatedBy(20240815L);
        int insert = flowUserMapper.insert(flowUser);
        if (insert > 0) {
            return Optional.of(flowUser);
        }
        return Optional.of(new FlowUser());
    }

    /**
     * Create multiple FlowUser.
     *
     * @param flowUsers multiple FlowUser to create
     * @return true if successfully created, or else false
     */
    @Override
    public Optional<Boolean> createFlowUserBatch(List<FlowUser> flowUsers) {
        boolean result = saveBatch(flowUsers);
        return Optional.of(result);
    }

    /**
     * Modify the specified FlowUser.
     *
     * @param id     The ID of the FlowUser to modify
     * @param latest A new info of FlowUser that needs to be modified
     * @return the FlowUser that has just been modified
     */
    @Override
    public Optional<FlowUser> modifyFlowUser(Long id, FlowUser latest) {
        if (Objects.isNull(id) || Objects.isNull(latest)) {
            return Optional.empty();
        }
        FlowUser existing = flowUserMapper.selectById(id);
        if (Objects.isNull(existing)) {
            throw new ServiceException("id为 '" + id + " 的记录不存在! ");
        }
        return flowUserMapper.updateById(latest) > 0 ? Optional.of(latest) : Optional.empty();
    }

    /**
     * Remove the specified FlowUser.
     *
     * @param id The ID of the FlowUser to remove
     * @return true if successfully removed, or else false
     */
    @Override
    public Optional<Long> deleteFlowUser(Long id) {
        FlowUser existing = flowUserMapper.selectById(id);
        if (Objects.isNull(existing)) {
            throw new ServiceException("id为 '" + id + " 的记录不存在! ");
        }
        return flowUserMapper.deleteById(id) > 0 ? Optional.of(id) : Optional.empty();
    }

    /**
     * Remove the specified FlowUser by a list of ids.
     *
     * @param ids A list of FlowUser ids to remove
     * @return true if successfully removed, or else false
     */
    @Override
    public Optional<Integer> deleteFlowUserBatch(Set<Long> ids) {
        int deleted = flowUserMapper.deleteBatchIds(ids);
        return deleted > 0 ? Optional.of(deleted) : Optional.empty();
    }

    /**
     * Get a FlowUser by the specified id.
     *
     * @param id The id of the specified FlowUser
     * @return An instance of {@code FlowUser}, or null if the id does not exist
     */
    @Override
    public Optional<FlowUser> getFlowUserDetailById(Long id) {
        FlowUser flowUser = flowUserMapper.selectById(id);
        return Optional.ofNullable(flowUser);
    }

    /**
     * Get FlowUsers based on specified criteria.
     *
     * @param flowUser the query conditions
     * @return A list of FlowUser.
     */
    @Override
    public IPage<FlowUser> pageFlowUser(FlowUser flowUser) {
        Page<FlowUser> page = Page.of(flowUser.getCurrent(), flowUser.getSize());
        String userId = "20240815";
        List<Long> businessKeys = Optional.ofNullable(taskMapper.getBusinessKeys(userId, null, page.getSize(), page.getCurrent()))
                .filter(ObjectUtils::isNotEmpty)
                .orElse(Arrays.asList(0L));

        log.info("businessKeys: {}", businessKeys);
        LambdaQueryWrapper<FlowUser> wrapper = new LambdaQueryWrapper<>();
        // Example: wrapper.like(flowUser.getName() != null, FlowUser::getName, flowUser.getName());
        //wrapper.and(e -> {
        //    e.eq(FlowUser::getCreatedBy, userId)
        //            .or().in(FlowUser::getId, businessKeys);
        //});
        wrapper.like(StringUtils.isNotBlank(flowUser.getName()), FlowUser::getName, flowUser.getName());
        wrapper.eq(Objects.nonNull(flowUser.getAge()), FlowUser::getAge, flowUser.getAge());
        wrapper.eq(Objects.nonNull(flowUser.getState()), FlowUser::getState, flowUser.getState());
        wrapper.eq(Objects.nonNull(flowUser.getStatus()), FlowUser::getStatus, flowUser.getStatus());
        wrapper.eq(Objects.nonNull(flowUser.getHandler()), FlowUser::getHandler, flowUser.getHandler());
        wrapper.eq(Objects.nonNull(flowUser.getCreatedTime()), FlowUser::getCreatedTime, flowUser.getCreatedTime());
        wrapper.eq(Objects.nonNull(flowUser.getModifyBy()), FlowUser::getModifyBy, flowUser.getModifyBy());
        wrapper.eq(Objects.nonNull(flowUser.getModifyTime()), FlowUser::getModifyTime, flowUser.getModifyTime());
        wrapper.eq(FlowUser::getCreatedBy, userId);
        wrapper.or().in(FlowUser::getId, businessKeys);
        wrapper.orderByDesc(FlowUser::getId);
        IPage<FlowUser> resultPage = flowUserMapper.selectPage(page, wrapper);
        resultPage.getRecords().forEach(e -> {
            e.setHandlerName(e.getHandler());
        });
        return resultPage;
    }

    /**
     * List FlowUsers based on specified criteria.
     *
     * @param flowUser the query parameters
     * @return A list of FlowUser
     */
    @Override
    public List<FlowUser> listFlowUser(FlowUser flowUser) {
        LambdaQueryWrapper<FlowUser> wrapper = new LambdaQueryWrapper<>(flowUser);
        // Example: wrapper.eq(flowUser.getStatus() != null, FlowUser::getStatus, flowUser.getStatus());
        return flowUserMapper.selectList(wrapper);
    }
}
