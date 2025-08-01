package cn.tdx.module.system.enums.permission;

import cn.tdx.framework.common.util.object.ObjectUtils;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 角色标识枚举
 */
@Getter
@AllArgsConstructor
public enum RoleCodeEnum {

    SUPER_ADMIN("super_admin", "超级管理员"), TENANT_ADMIN("tenant_admin", "租户管理员"), CRM_ADMIN("crm_admin", "CRM 管理员"), // CRM
                                                                                                                   // 系统专用
    YXFXS("yxfxs", "一线分析师"), EXFXS("exfxs", "二线分析师"), BMAQY("bmaqy", "部门安全员");

    /**
     * 角色编码
     */
    private final String code;
    /**
     * 名字
     */
    private final String name;

    public static boolean isSuperAdmin(String code) {
        return ObjectUtils.equalsAny(code, SUPER_ADMIN.getCode());
    }

}
