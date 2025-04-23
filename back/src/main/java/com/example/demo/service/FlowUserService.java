package com.example.demo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.example.demo.entity.FlowUser;

import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * The 流程测试 service.
 *
 * @author chonghui.tian
 * @since 2025-04-22
 */
public interface FlowUserService extends IService<FlowUser> {

    /**
     * Create a FlowUser.
     *
     * @param flowUser A new FlowUser to create
     * @return The instance of {@link FlowUser} that was just created
     */
    Optional<FlowUser> createFlowUser(FlowUser flowUser);

    /**
     * Create multiple FlowUser.
     *
     * @param flowUsers multiple FlowUser to create
     * @return created num
     */
    Optional<Boolean> createFlowUserBatch(List<FlowUser> flowUsers);

    /**
     * Modify the specified FlowUser.
     *
     * @param id The ID of the FlowUser to modify
     * @param latest A new info of FlowUser that needs to be modified
     * @return the FlowUser that has just been modified
     */
    Optional<FlowUser> modifyFlowUser(Long id, FlowUser latest);

    /**
     * Remove the specified FlowUser.
     *
     * @param id The ID of the FlowUser to remove
     * @return true if successfully removed, or else false
     */
    Optional<Long> deleteFlowUser(Long id);

    /**
     * Remove the specified FlowUser.
     *
     * @param ids A list of FlowUser id to remove
     * @return true if successfully removed, or else false
     */
    Optional<Integer> deleteFlowUserBatch(Set<Long> ids);

    /**
     * Get a FlowUser according to the specified id.
     *
     * @param id The id of the specified FlowUser
     * @return An instance of {@link FlowUser}, or null if the id does not exist
     */
    Optional<FlowUser> getFlowUserDetailById(Long id);

    /**
     * Paging FlowUser based on specified criteria.
     *
     * @param flowUser the query parameters
     * @return A page of FlowUser
     */
    IPage<FlowUser> pageFlowUser(FlowUser flowUser);

    /**
     * List FlowUser based on specified criteria.
     *
     * @param flowUser the query parameters
     * @return A list of FlowUser
     */
    List<FlowUser> listFlowUser(FlowUser flowUser);
}
