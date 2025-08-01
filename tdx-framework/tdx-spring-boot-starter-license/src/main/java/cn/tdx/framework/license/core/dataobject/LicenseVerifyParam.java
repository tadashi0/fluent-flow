package cn.tdx.framework.license.core.dataobject;

import lombok.Data;

/**
 * License校验类需要的参数
 * @author zwj
 */
@Data
public class LicenseVerifyParam {
    private static final long serialVersionUID = 1L;

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
     * 证书生成路径
     */
    private String licensePath;

    /**
     * 密钥库存储路径
     */
    private String publicKeysStorePath;

    /**
     * 是否为绝对路径*
     */
    private Boolean isAbs;

    public LicenseVerifyParam() {

    }

    public LicenseVerifyParam(String subject, String publicAlias, String storePass, String licensePath, String publicKeysStorePath) {
        this.subject = subject;
        this.publicAlias = publicAlias;
        this.storePass = storePass;
        this.licensePath = licensePath;
        this.publicKeysStorePath = publicKeysStorePath;
    }

    @Override
    public String toString() {
        return "LicenseVerifyParam{" +
                "subject='" + subject + '\'' +
                ", publicAlias='" + publicAlias + '\'' +
                ", storePass='" + storePass + '\'' +
                ", licensePath='" + licensePath + '\'' +
                ", publicKeysStorePath='" + publicKeysStorePath + '\'' +
                ", isAbs='" + isAbs + '\'' +
                '}';
    }
}
