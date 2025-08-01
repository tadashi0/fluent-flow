package cn.tdx.framework.license.config;

import cn.tdx.framework.license.core.interceptor.LicenseCheckInterceptor;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@AutoConfiguration
@EnableConfigurationProperties(LicenseProperties.class)
public class TdxLicenseAutoConfiguration implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LicenseCheckInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/license/getInfo", "/license/restLicense");
    }
}
