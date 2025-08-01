package cn.tdx.framework.license.core.utils;

import cn.tdx.framework.license.config.LicenseProperties;
import cn.tdx.framework.license.core.dataobject.CustomKeyStoreParam;
import cn.tdx.framework.license.core.dataobject.LicenseContentVo;
import cn.tdx.framework.license.core.dataobject.LicenseVerifyParam;
import de.schlichtherle.license.*;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;

import javax.naming.ldap.LdapName;
import javax.security.auth.x500.X500Principal;
import java.io.File;
import java.text.DateFormat;
import java.text.MessageFormat;
import java.text.SimpleDateFormat;
import java.util.concurrent.atomic.AtomicReference;
import java.util.prefs.Preferences;

/**
 * License校验类
 *
 * @author zwj
 */
@Slf4j
public class LicenseVerify {

    @Resource
    private LicenseProperties licenseProperties;

    /**
     * 安装License证书
     */
    public synchronized void install(LicenseVerifyParam param) {
        LicenseContent result;
        DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        try {
            LicenseManager licenseManager = LicenseManagerHolder.getInstance(initLicenseParam(param));
            File file = getLicenseFile(param);
            licenseManager.uninstall();
            result = licenseManager.install(file);
            log.info(MessageFormat.format("证书安装成功，证书有效期：{0} - {1}", format.format(result.getNotBefore()), format.format(result.getNotAfter())));
        } catch (Exception e) {
            log.error("证书安装失败！", e);
        }

    }

    /**
     * 获取License文件
     */
    private File getLicenseFile(LicenseVerifyParam param) {
        if (param.getIsAbs()) {
            return new File(param.getLicensePath());
        } else {
            // 使用File.separator确保在不同操作系统上路径分隔符正确
            return new File(licenseProperties.getLicensePath() + File.separator + licenseProperties.getName());
        }
    }

    /**
     * 校验License证书
     */
    public boolean verify() {
        LicenseManager licenseManager = LicenseManagerHolder.getInstance(null);
        //2. 校验证书
        try {
            LicenseContent licenseContent = licenseManager.verify();
            return licenseContent != null;
        } catch (Exception e) {
            log.error("证书校验失败！", e);
            return false;
        }
    }

    /**
     * 初始化证书生成参数
     */
    private LicenseParam initLicenseParam(LicenseVerifyParam param) {
        Preferences preferences = Preferences.userNodeForPackage(LicenseVerify.class);

        CipherParam cipherParam = new DefaultCipherParam(param.getStorePass());

        KeyStoreParam publicStoreParam = new CustomKeyStoreParam(LicenseVerify.class
                , param.getPublicKeysStorePath()
                , param.getPublicAlias()
                , param.getStorePass()
                , null, param.getIsAbs());

        return new DefaultLicenseParam(param.getSubject()
                , preferences
                , publicStoreParam
                , cipherParam);
    }

    public LicenseContentVo getLicenseInfo() {
        LicenseContentVo contentVo = new LicenseContentVo();
        LicenseManager licenseManager = LicenseManagerHolder.getInstance(null);
        //2. 校验证书
        try {
            LicenseContent licenseContent = licenseManager.verify();
            X500Principal holder = licenseContent.getHolder();
            String dnString = holder.toString();
            LdapName ldapName = new LdapName(dnString);
            AtomicReference<String> orgName = new AtomicReference<>();
            AtomicReference<String> name = new AtomicReference<>();
            AtomicReference<String> phone = new AtomicReference<>();
            AtomicReference<String> email = new AtomicReference<>();
            ldapName.getRdns().forEach(e -> {
                switch (e.getType()) {
                    case "CN" -> name.set(e.getValue().toString());
                    case "UID" -> phone.set(e.getValue().toString());
                    case "O" -> orgName.set(e.getValue().toString());
                    case "EMAILADDRESS" -> email.set(e.getValue().toString());
                    default -> {
                    }
                }
            });
            contentVo = new LicenseContentVo(orgName.get(), name.get(), phone.get(), email.get(), licenseContent.getNotAfter());
        } catch (Exception e) {
            log.error("证书校验失败！", e);
        }
        return contentVo;
    }
}
