package cn.tdx.module.system.dal.mysql.user;

import cn.tdx.framework.common.pojo.PageResult;
import cn.tdx.framework.mybatis.core.mapper.BaseMapperX;
import cn.tdx.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.tdx.framework.mybatis.core.query.MPJLambdaWrapperX;
import cn.tdx.module.system.controller.admin.user.vo.user.UserPageReqVO;
import cn.tdx.module.system.dal.dataobject.permission.UserRoleDO;
import cn.tdx.module.system.dal.dataobject.user.AdminUserDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.Collection;
import java.util.List;

@Mapper
public interface AdminUserMapper extends BaseMapperX<AdminUserDO> {

    default AdminUserDO selectByUsername(String username) {
        return selectOne(AdminUserDO::getUsername, username);
    }

    default AdminUserDO selectByEmail(String email) {
        return selectOne(AdminUserDO::getEmail, email);
    }

    default AdminUserDO selectByMobile(String mobile) {
        return selectOne(AdminUserDO::getMobile, mobile);
    }

    default PageResult<AdminUserDO> selectPage(UserPageReqVO reqVO, Collection<Long> deptIds,
        Collection<Long> userIds) {
        return selectPage(reqVO,
            new LambdaQueryWrapperX<AdminUserDO>().likeIfPresent(AdminUserDO::getUsername, reqVO.getUsername())
                    .likeIfPresent(AdminUserDO::getNickname, reqVO.getNickname())
                .likeIfPresent(AdminUserDO::getMobile, reqVO.getMobile())
                .eqIfPresent(AdminUserDO::getStatus, reqVO.getStatus())
                .betweenIfPresent(AdminUserDO::getCreateTime, reqVO.getCreateTime())
                .inIfPresent(AdminUserDO::getDeptId, deptIds).inIfPresent(AdminUserDO::getId, userIds)
                .orderByDesc(AdminUserDO::getId));
    }

    default List<AdminUserDO> selectListByNickname(String nickname) {
        return selectList(new LambdaQueryWrapperX<AdminUserDO>().like(AdminUserDO::getNickname, nickname));
    }

    default List<AdminUserDO> selectListByStatus(Integer status) {
        return selectList(AdminUserDO::getStatus, status);
    }

    default List<AdminUserDO> selectListByDeptIds(Collection<Long> deptIds) {
        return selectList(AdminUserDO::getDeptId, deptIds);
    }

    default List<AdminUserDO> getUserListByRoleIds(Collection<String> roles){
        MPJLambdaWrapperX<AdminUserDO> query = new MPJLambdaWrapperX<>();
        query.innerJoin(UserRoleDO.class,
                on -> on.eq(UserRoleDO::getUserId, AdminUserDO::getId).in(UserRoleDO::getRoleId, roles));
        return selectList(query);
    }

    default List<AdminUserDO> selectListByDeptIdsAndRoleIds(Collection<Long> deptIds, Collection<String> roles) {
        MPJLambdaWrapperX<AdminUserDO> query = new MPJLambdaWrapperX<>();
        query.inIfPresent(AdminUserDO::getDeptId, deptIds);
        query.innerJoin(UserRoleDO.class,
            on -> on.eq(UserRoleDO::getRoleId, AdminUserDO::getId).in(UserRoleDO::getRoleId, roles));
        return selectList(query);
    }
}
