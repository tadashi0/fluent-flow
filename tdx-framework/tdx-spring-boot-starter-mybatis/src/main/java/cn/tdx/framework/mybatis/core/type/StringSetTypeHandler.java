package cn.tdx.framework.mybatis.core.type;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.ibatis.type.JdbcType;
import org.apache.ibatis.type.MappedJdbcTypes;
import org.apache.ibatis.type.MappedTypes;
import org.apache.ibatis.type.TypeHandler;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;

/**
 * Set<String> 的类型转换器实现类，对应数据库的 varchar 类型
 *
 * @author zwj
 * @since 2025 4/3 12:50:15
 */
@MappedJdbcTypes(JdbcType.VARCHAR)
@MappedTypes(Set.class)
public class StringSetTypeHandler implements TypeHandler<Set<String>> {

    private static final String COMMA = ",";

    @Override
    public void setParameter(PreparedStatement ps, int i, Set<String> strings, JdbcType jdbcType) throws SQLException {
        // 设置占位符
        ps.setString(i, CollUtil.join(strings, COMMA));
    }

    @Override
    public Set<String> getResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return getResult(value);
    }

    @Override
    public Set<String> getResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return getResult(value);
    }

    @Override
    public Set<String> getResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return getResult(value);
    }

    private Set<String> getResult(String value) {
        if (value == null) {
            return null;
        }
        List<String> list = StrUtil.splitTrim(value, COMMA);
        return new HashSet<>(list);
    }
}
