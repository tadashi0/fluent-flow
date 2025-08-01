package cn.tdx.module;

import cn.tdx.module.service.MysqlService;
import org.springframework.ai.tool.ToolCallbackProvider;
import org.springframework.ai.tool.method.MethodToolCallbackProvider;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

/**
 * @author Chenke Zhao
 * @date 2025/7/28 17:07
 * @description McpApplication
 */


@SpringBootApplication
public class McpServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(McpServerApplication.class, args);
    }

    @Bean
    public ToolCallbackProvider weatherTools(MysqlService mysqlService) {
        return  MethodToolCallbackProvider.builder().toolObjects(mysqlService).build();
    }
}

















