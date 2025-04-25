package com.wf.mapper;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.*;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;


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
            "AND table_name NOT LIKE 'flw%' " +
            "AND table_name NOT LIKE 'flyway%' " +
            "<if test='tableName != null'> AND table_name LIKE CONCAT('%', #{tableName}, '%') </if>" +
            "</script>")
    List<TableInfoDTO> getTableInfoList(@Param("tableName") String tableName);
}
