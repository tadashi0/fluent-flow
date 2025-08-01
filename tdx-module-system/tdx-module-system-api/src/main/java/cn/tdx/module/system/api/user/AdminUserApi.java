package cn.tdx.module.system.api.user;

import cn.tdx.framework.common.util.collection.CollectionUtils;
import cn.tdx.module.system.api.user.dto.AdminUserRespDTO;

import java.util.*;

/**
 * Admin 用户 API 接口
 *
 * @author 嗒哒西
 */
public interface AdminUserApi {

    /**
     * 通过用户 ID 查询用户
     *
     * @param id 用户ID
     * @return 用户对象信息
     */
    AdminUserRespDTO getUser(Long id);

    /**
     * 通过用户 ID 查询用户下属
     *
     * @param id 用户编号
     * @return 用户下属用户列表
     */
    List<AdminUserRespDTO> getUserListBySubordinate(Long id);

    /**
     * 获取指定用户的第N级领导（单个）
     *
     * @param userId 用户ID
     * @param level 级别（1表示直接上级，2表示上级的上级，依此类推）
     * @return 第N级领导用户信息，如果不存在则返回null
     */
    AdminUserRespDTO getNthLevelLeader(Long userId, Integer level);

    /**
     * 获取指定用户的前N级领导列表
     * 返回从直接上级开始的前N级领导
     * List的第一条是直接上级，然后是上级的上级，依次往上
     *
     * @param userId 用户ID
     * @param level 级别（获取前N级领导）
     * @return 前N级领导列表，按级别从低到高排序，如果没有上级则返回空列表
     */
    List<AdminUserRespDTO> getNthLevelLeaderList(Long userId, Integer level);

    /**
     * 获取指定用户的所有上级领导链（到最高级）
     * 返回从直接上级到最高级领导的完整领导链列表
     * List的第一条是直接上级，最后一条是最高级领导
     *
     * @param userId 用户ID
     * @return 完整领导链列表，按级别从低到高排序，如果没有上级则返回空列表
     */
    List<AdminUserRespDTO> getAllLeaderChain(Long userId);

    /**
     * 通过用户 ID 查询用户们
     *
     * @param ids 用户 ID 们
     * @return 用户对象信息
     */
    List<AdminUserRespDTO> getUserList(Collection<Long> ids);

    /**
     * 获取所有用户
     *
     * @return 用户对象信息
     */
    List<AdminUserRespDTO> getAllUserList();

    /**
     * 获得指定部门的用户数组
     *
     * @param deptIds 部门数组
     * @return 用户数组
     */
    List<AdminUserRespDTO> getUserListByDeptIds(Collection<Long> deptIds);

    /**
     * 获得指定角色的用户数组
     *
     * @param roles 角色数组
     * @return 用户数组
     */
    List<AdminUserRespDTO> getUserListByRoleIds(Collection<String> roles);

    /**
     * 获得指定部门的指定角色的用户数组
     *
     * @param deptIds 部门数组
     * @param roles 角色数组
     * @return 用户数组
     */
    List<AdminUserRespDTO> getUserListByDeptIdsAndRoleIds(Collection<Long> deptIds, Collection<String> roles);

    /**
     * 获得指定岗位的用户数组
     *
     * @param postIds 岗位数组
     * @return 用户数组
     */
    List<AdminUserRespDTO> getUserListByPostIds(Collection<Long> postIds);

    /**
     * 获得用户 Map
     *
     * @param ids 用户编号数组
     * @return 用户 Map
     */
    default Map<Long, AdminUserRespDTO> getUserMap(Collection<Long> ids) {
        List<AdminUserRespDTO> users = getUserList(ids);
        return CollectionUtils.convertMap(users, AdminUserRespDTO::getId);
    }

    /**
     * 校验用户是否有效。如下情况，视为无效： 1. 用户编号不存在 2. 用户被禁用
     *
     * @param id 用户编号
     */
    default void validateUser(Long id) {
        validateUserList(Collections.singleton(id));
    }

    /**
     * 校验用户们是否有效。如下情况，视为无效： 1. 用户编号不存在 2. 用户被禁用
     *
     * @param ids 用户编号数组
     */
    void validateUserList(Collection<Long> ids);
}
