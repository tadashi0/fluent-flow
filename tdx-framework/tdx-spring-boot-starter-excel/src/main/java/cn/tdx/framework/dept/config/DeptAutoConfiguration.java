package cn.tdx.framework.dept.config;

import cn.tdx.framework.dept.core.DeptFrameworkUtils;
import cn.tdx.module.system.api.dept.DeptApi;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.context.annotation.Bean;


@AutoConfiguration
public class DeptAutoConfiguration {

    @Bean
    @SuppressWarnings("InstantiationOfUtilityClass")
    public DeptFrameworkUtils deptUtils(DeptApi deptApi) {
        DeptFrameworkUtils.init(deptApi);
        return new DeptFrameworkUtils();
    }

}
