package cn.tdx.module.system.dal.mysql.tenant;

import cn.tdx.framework.common.pojo.PageResult;
import cn.tdx.framework.mybatis.core.mapper.BaseMapperX;
import cn.tdx.framework.mybatis.core.query.LambdaQueryWrapperX;
import cn.tdx.module.system.controller.admin.tenant.vo.packages.TenantPackagePageReqVO;
import cn.tdx.module.system.dal.dataobject.tenant.TenantPackageDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

/**
 * 租户套餐 Mapper
 *
 * @author 安迈源码
 */
@Mapper
public interface TenantPackageMapper extends BaseMapperX<TenantPackageDO> {

    default PageResult<TenantPackageDO> selectPage(TenantPackagePageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<TenantPackageDO>()
                .likeIfPresent(TenantPackageDO::getName, reqVO.getName())
                .eqIfPresent(TenantPackageDO::getStatus, reqVO.getStatus())
                .likeIfPresent(TenantPackageDO::getRemark, reqVO.getRemark())
                .betweenIfPresent(TenantPackageDO::getCreateTime, reqVO.getCreateTime())
                .orderByDesc(TenantPackageDO::getId));
    }

    default List<TenantPackageDO> selectListByStatus(Integer status) {
        return selectList(TenantPackageDO::getStatus, status);
    }

    default TenantPackageDO selectByName(String name) {
        return selectOne(TenantPackageDO::getName, name);
    }
}
