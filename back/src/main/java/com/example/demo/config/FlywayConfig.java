package com.example.demo.config;

import com.alibaba.druid.pool.DruidDataSource;
import com.baomidou.dynamic.datasource.DynamicRoutingDataSource;
import com.baomidou.dynamic.datasource.ds.ItemDataSource;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.annotation.PostConstruct;
import javax.sql.DataSource;
import java.sql.*;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author chonghui. tian
 * date 2024/5/17 15:52
 * description 自动生成数据库和表配置类
 */
@Slf4j
@Configuration
@RequiredArgsConstructor
@EnableTransactionManagement
public class FlywayConfig {

    private final DataSource dataSource;

    @Value("${spring.flyway.locations}")
    private String SQL_LOCATION;

    @Value("${spring.flyway.baseline-on-migrate}")
    private boolean BASELINE_ON_MIGRATE;

    @Value("${spring.flyway.out-of-order}")
    private boolean OUT_OF_ORDER;

    @Value("${spring.flyway.validate-on-migrate}")
    private boolean VALIDATE_ON_MIGRATE;

    private static boolean databaseExists(Connection conn, String dbName) throws SQLException {
        ResultSet resultSet = conn.getMetaData().getCatalogs();
        while (resultSet.next()) {
            if (dbName.equals(resultSet.getString(1))) {
                return true; // 找到匹配的数据库
            }
        }
        return false;
    }

    @PostConstruct
    public void migrateOrder() {
        log.info("调用数据库生成工具");
        SQL_LOCATION = SQL_LOCATION.split("/")[0]; // 将路径转换
        DynamicRoutingDataSource ds = (DynamicRoutingDataSource) dataSource;
        Map<String, DataSource> dataSources = ds.getDataSources();
        dataSources.forEach((k, v) -> {
            DruidDataSource rds = (DruidDataSource) ((ItemDataSource) v).getRealDataSource();
            String rawJdbcUrl = rds.getRawJdbcUrl();
            Matcher matcher = Pattern.compile("(jdbc:mysql://[^/]+)/([^?]+)").matcher(rawJdbcUrl);
            if (matcher.find()) {
                String connectUrl = matcher.group(1);
                String dbName = matcher.group(2);
                // 如果数据库不存在则创建数据库
                try (Connection connection = DriverManager.getConnection(connectUrl, rds.getUsername(), rds.getPassword());
                     Statement statement = connection.createStatement()) {
                    if (!databaseExists(connection, dbName)) {
                        statement.executeUpdate("CREATE DATABASE IF NOT EXISTS `" + dbName + "` DEFAULT CHARACTER SET = `utf8mb4` COLLATE `utf8mb4_general_ci`;");
                        log.info("数据库: {} 初始化创建成功!", dbName);
                    }
                } catch (SQLException e) {
                    log.error("数据库: {} 初始化创建失败!", dbName);
                    throw new RuntimeException(e);
                }
                log.info("正在执行数据源: {} 的SQL脚本", k);
                Flyway flyway = Flyway.configure()
                        .dataSource(v)
                        .locations(SQL_LOCATION + "/" + k)
                        .baselineOnMigrate(BASELINE_ON_MIGRATE)
                        .outOfOrder(OUT_OF_ORDER)
                        .validateOnMigrate(VALIDATE_ON_MIGRATE)
                        .load();
                flyway.migrate();
            }
        });
    }
}
