package cn.tdx.module.workflow.mapper;

import cn.tdx.module.workflow.dal.FieldInfoDTO;
import cn.tdx.module.workflow.dal.TableInfoDTO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;


/**
 * @author chonghui. tian
 * date 2025/4/18 11:47
 * description
 */
@Mapper
public interface ProcessMapper {

    @Select("<script>" +
            "SELECT table_name AS tableName, table_comment AS tableComment " +
            "FROM information_schema.tables " +
            "WHERE TABLE_SCHEMA = DATABASE() " +
            "AND table_name NOT LIKE 'flw_%' " +
            "AND table_name NOT LIKE 'flyway_%' " +
            "AND table_name NOT LIKE 'infra_%' " +
            "AND table_name NOT LIKE 'system_%' " +
            "AND table_name NOT LIKE 'qrtz_%' " +
            "<if test='tableName != null'> AND table_name LIKE CONCAT('%', #{tableName}, '%') </if>" +
                    "</script>")
    List<TableInfoDTO> getTableInfoList(@Param("tableName") String tableName);

    @Select("SELECT " +
            "column_comment AS label, " +
            "column_name AS field " +
            "FROM information_schema.columns " +
            "WHERE table_schema = DATABASE() " +
            "AND table_name = #{tableName} " +
            "ORDER BY ordinal_position")
    List<FieldInfoDTO> getFieldInfoList(@Param("tableName") String tableName);
}
