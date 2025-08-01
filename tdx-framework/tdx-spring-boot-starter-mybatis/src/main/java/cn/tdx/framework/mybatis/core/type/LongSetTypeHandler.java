package cn.tdx.framework.mybatis.core.type;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import cn.tdx.framework.common.util.string.StrUtils;
import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.apache.ibatis.type.TypeHandler;

import cn.hutool.core.collection.CollUtil;

@MappedJdbcTypes(JdbcType.VARCHAR)
@MappedTypes(Set.class)
public class LongSetTypeHandler implements TypeHandler<Set<Long>> {

    private static final String COMMA = ",";

    @Override
    public void setParameter(PreparedStatement ps, int i, Set<Long> strings, JdbcType jdbcType) throws SQLException {
        // 设置占位符
        ps.setString(i, CollUtil.join(strings, COMMA));
    }

    @Override
    public Set<Long> getResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return getResult(value);
    }

    @Override
    public Set<Long> getResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return getResult(value);
    }

    @Override
    public Set<Long> getResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return getResult(value);
    }

    private Set<Long> getResult(String value) {
        if (value == null) {
            return null;
        }
        List<Long> list = StrUtils.splitToLong(value, COMMA);
        return new HashSet<>(list);
    }
}
