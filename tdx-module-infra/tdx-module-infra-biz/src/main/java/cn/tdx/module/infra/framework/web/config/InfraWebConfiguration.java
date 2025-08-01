package cn.tdx.module.infra.framework.web.config;

import cn.tdx.framework.swagger.config.TdxSwaggerAutoConfiguration;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * infra 模块的 web 组件的 Configuration
 *
 * @author 嗒哒西
 */
@Configuration(proxyBeanMethods = false)
public class InfraWebConfiguration {

    /**
     * infra 模块的 API 分组
     */
    @Bean
    public GroupedOpenApi infraGroupedOpenApi() {
        return TdxSwaggerAutoConfiguration.buildGroupedOpenApi("infra");
    }

}
