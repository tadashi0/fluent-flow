package cn.tdx.framework.license.core.listener;

import cn.tdx.framework.license.config.LicenseProperties;
import cn.tdx.framework.license.core.dataobject.LicenseVerifyParam;
import cn.tdx.framework.license.core.utils.LicenseVerify;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;
import org.springframework.stereotype.Component;

/**
 * 在项目启动时安装证书
 *
 * @author zwj
 */

@Component
@Slf4j
public class LicenseCheckListener implements ApplicationListener<ContextRefreshedEvent> {

    @Resource
    private LicenseProperties licenseProperties;

    @Override
    public void onApplicationEvent(ContextRefreshedEvent event) {
        log.info("++++++++ 开始安装证书 ++++++++");
        LicenseVerifyParam param = new LicenseVerifyParam();
        param.setSubject(licenseProperties.getSubject());
        param.setPublicAlias(licenseProperties.getPublicAlias());
        param.setStorePass(licenseProperties.getStorePass());
        param.setLicensePath(licenseProperties.getLicensePath());
        param.setPublicKeysStorePath(licenseProperties.getPublicKeysStoreFile());
        param.setIsAbs(licenseProperties.getIsAbs());
        LicenseVerify licenseVerify = new LicenseVerify();
        licenseVerify.install(param);
        log.info("++++++++ 证书安装结束 ++++++++");
    }
}
