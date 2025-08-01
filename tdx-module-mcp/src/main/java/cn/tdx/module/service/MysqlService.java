package cn.tdx.module.service;

import jakarta.annotation.Resource;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * @author Chenke Zhao
 * @date 2025/7/28 14:58
 * @description MysqlService
 */
@Service
public class MysqlService {

    @Resource
    private JdbcTemplate jdbcTemplate;

    @Tool(description = "根据ip和端口查询资产信息")
    public String queryAssetInfo(String ip,   //ip
                                 String port  //端口
    ) {
        String sql = "select * from asset where ip = ? and port = ?";
        try {
            return jdbcTemplate.queryForObject(sql, new Object[]{ip, port}, (rs, rowNum) -> rs.getString("name") + " " + rs.getString("ip") + " " + rs.getString("port"));
        } catch (Exception e) {
            return "查询失败";
        }
    }


}
