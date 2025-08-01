package cn.tdx.framework.license.core.dataobject;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

/**
 * license包含信息展示 *
 *
 * @author zwj
 */
@AllArgsConstructor
@NoArgsConstructor
@Data
public class LicenseContentVo {
    /**
     * 组织*
     */
    private String orgName;
    /**
     * 联系人姓名*
     */
    private String name;
    /**
     * 联系方式*
     */
    private String phone;
    /**
     * 邮箱*
     */
    private String email;
    /**
     * 证书失效时间
     */
    private Date expiryTime;
}
