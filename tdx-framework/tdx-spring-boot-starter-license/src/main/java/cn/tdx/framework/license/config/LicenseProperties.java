package cn.tdx.framework.license.config;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@ConfigurationProperties(prefix = "tdx.license")
@Validated
@Data
public class LicenseProperties {

    @NotNull(message = "license名称 不能为空")
    private String name;

    private String licensePath;
    /**
     * 证书subject
     */
    private String subject;
    /**
     * 公钥别称
     */
    private String publicAlias;
    /**
     * 访问公钥库的密码
     */
    private String storePass;
    /**
     * 密钥库存储路径
     */
    private String publicKeysStoreFile;
    /**
     * 密钥库存储路径
     */
    private Boolean isAbs;

}
