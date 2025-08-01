package cn.tdx.module.infra.dal.mysql.db;

import cn.tdx.framework.mybatis.core.mapper.BaseMapperX;
import cn.tdx.module.infra.dal.dataobject.db.DataSourceConfigDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 数据源配置 Mapper
 *
 * @author 安迈源码
 */
@Mapper
public interface DataSourceConfigMapper extends BaseMapperX<DataSourceConfigDO> {
}
