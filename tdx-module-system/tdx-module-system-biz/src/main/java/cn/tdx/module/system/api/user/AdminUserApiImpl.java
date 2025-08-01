package cn.tdx.module.system.api.user;

import cn.tdx.framework.common.pojo.PageParam;
import cn.tdx.framework.common.pojo.PageResult;
import cn.tdx.module.system.controller.admin.user.vo.user.UserPageReqVO;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.ObjUtil;
import cn.tdx.framework.common.util.object.BeanUtils;
import cn.tdx.framework.datapermission.core.annotation.DataPermission;
import cn.tdx.module.system.api.user.dto.AdminUserRespDTO;
import cn.tdx.module.system.dal.dataobject.dept.DeptDO;
import cn.tdx.module.system.dal.dataobject.user.AdminUserDO;
import cn.tdx.module.system.service.dept.DeptService;
import cn.tdx.module.system.service.user.AdminUserService;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;

import java.util.*;

import static cn.tdx.framework.common.util.collection.CollectionUtils.convertSet;

/**
 * Admin 用户 API 实现类
 *
 * @author 嗒哒西
 */
@Service
public class AdminUserApiImpl implements AdminUserApi {

    @Resource
    private AdminUserService userService;
    @Resource
    private DeptService deptService;

    @Override
    public AdminUserRespDTO getUser(Long id) {
        AdminUserDO user = userService.getUser(id);
        return BeanUtils.toBean(user, AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getUserListBySubordinate(Long id) {
        // 1.1 获取用户负责的部门
        List<DeptDO> depts = deptService.getDeptListByLeaderUserId(id);
        if (CollUtil.isEmpty(depts)) {
            return Collections.emptyList();
        }
        // 1.2 获取所有子部门
        Set<Long> deptIds = convertSet(depts, DeptDO::getId);
        List<DeptDO> childDeptList = deptService.getChildDeptList(deptIds);
        if (CollUtil.isNotEmpty(childDeptList)) {
            deptIds.addAll(convertSet(childDeptList, DeptDO::getId));
        }

        // 2. 获取部门对应的用户信息
        List<AdminUserDO> users = userService.getUserListByDeptIds(deptIds);
        users.removeIf(item -> ObjUtil.equal(item.getId(), id)); // 排除自己
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public AdminUserRespDTO getNthLevelLeader(Long userId, Integer level) {
        if (userId == null || level == null || level <= 0) {
            return null;
        }

        AdminUserDO currentUser = userService.getUser(userId);
        if (currentUser == null || currentUser.getDeptId() == null) {
            return null;
        }

        DeptDO currentDept = deptService.getDept(currentUser.getDeptId());
        if (currentDept == null) {
            return null;
        }

        // 循环向上查找指定级别的领导
        for (int i = 0; i < level; i++) {
            // 查找当前部门的上级部门
            if (currentDept.getParentId() == null || currentDept.getParentId() == 0) {
                // 已经到达顶级部门，没有更上级的领导
                return null;
            }

            DeptDO parentDept = deptService.getDept(currentDept.getParentId());
            if (parentDept == null || parentDept.getLeaderUserId() == null) {
                // 上级部门不存在或没有设置领导
                return null;
            }

            // 如果是最后一级，返回这个领导
            if (i == level - 1) {
                AdminUserDO leader = userService.getUser(parentDept.getLeaderUserId());
                return BeanUtils.toBean(leader, AdminUserRespDTO.class);
            }

            // 继续向上查找
            currentDept = parentDept;
        }

        return null;
    }

    @Override
    public List<AdminUserRespDTO> getNthLevelLeaderList(Long userId, Integer level) {
        List<AdminUserRespDTO> leaderList = new ArrayList<>();

        if (userId == null || level == null || level <= 0) {
            return leaderList;
        }

        AdminUserDO currentUser = userService.getUser(userId);
        if (currentUser == null || currentUser.getDeptId() == null) {
            return leaderList;
        }

        DeptDO currentDept = deptService.getDept(currentUser.getDeptId());
        if (currentDept == null) {
            return leaderList;
        }

        // 循环向上查找前N级领导
        for (int i = 0; i < level; i++) {
            // 查找当前部门的上级部门
            if (currentDept.getParentId() == null || currentDept.getParentId() == 0) {
                // 已经到达顶级部门，跳出循环
                break;
            }

            DeptDO parentDept = deptService.getDept(currentDept.getParentId());
            if (parentDept == null) {
                // 上级部门不存在，跳出循环
                break;
            }

            // 如果上级部门有领导，添加到领导列表中
            if (parentDept.getLeaderUserId() != null) {
                AdminUserDO leader = userService.getUser(parentDept.getLeaderUserId());
                if (leader != null) {
                    leaderList.add(BeanUtils.toBean(leader, AdminUserRespDTO.class));
                }
            }

            // 继续向上查找
            currentDept = parentDept;
        }

        return leaderList;
    }

    @Override
    public List<AdminUserRespDTO> getAllLeaderChain(Long userId) {
        List<AdminUserRespDTO> leaderChain = new ArrayList<>();

        if (userId == null) {
            return leaderChain;
        }

        AdminUserDO currentUser = userService.getUser(userId);
        if (currentUser == null || currentUser.getDeptId() == null) {
            return leaderChain;
        }

        DeptDO currentDept = deptService.getDept(currentUser.getDeptId());
        if (currentDept == null) {
            return leaderChain;
        }

        // 循环向上查找所有级别的领导
        while (currentDept != null) {
            // 查找当前部门的上级部门
            if (currentDept.getParentId() == null || currentDept.getParentId() == 0) {
                // 已经到达顶级部门，跳出循环
                break;
            }

            DeptDO parentDept = deptService.getDept(currentDept.getParentId());
            if (parentDept == null) {
                // 上级部门不存在，跳出循环
                break;
            }

            // 如果上级部门有领导，添加到领导链中
            if (parentDept.getLeaderUserId() != null) {
                AdminUserDO leader = userService.getUser(parentDept.getLeaderUserId());
                if (leader != null) {
                    leaderChain.add(BeanUtils.toBean(leader, AdminUserRespDTO.class));
                }
            }

            // 继续向上查找
            currentDept = parentDept;
        }

        return leaderChain;
    }

    @Override
    @DataPermission(enable = false) // 禁用数据权限。原因是，一般基于指定 id 的 API 查询，都是数据拼接为主
    public List<AdminUserRespDTO> getUserList(Collection<Long> ids) {
        List<AdminUserDO> users = userService.getUserList(ids);
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getAllUserList() {
        UserPageReqVO userPageReqVO = new UserPageReqVO();
        userPageReqVO.setPageSize(PageParam.PAGE_SIZE_NONE);
        PageResult<AdminUserDO> userPage = userService.getUserPage(userPageReqVO);
        return BeanUtils.toBean(userPage.getList(), AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getUserListByDeptIds(Collection<Long> deptIds) {
        List<AdminUserDO> users = userService.getUserListByDeptIds(deptIds);
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getUserListByRoleIds(Collection<String> roles) {
        List<AdminUserDO> users = userService.getUserListByRoleIds(roles);
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getUserListByDeptIdsAndRoleIds(Collection<Long> deptIds, Collection<String> roles) {
        List<AdminUserDO> users = userService.getUserListByDeptIdsAndRoleIds(deptIds, roles);
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public List<AdminUserRespDTO> getUserListByPostIds(Collection<Long> postIds) {
        List<AdminUserDO> users = userService.getUserListByPostIds(postIds);
        return BeanUtils.toBean(users, AdminUserRespDTO.class);
    }

    @Override
    public void validateUserList(Collection<Long> ids) {
        userService.validateUserList(ids);
    }

}
