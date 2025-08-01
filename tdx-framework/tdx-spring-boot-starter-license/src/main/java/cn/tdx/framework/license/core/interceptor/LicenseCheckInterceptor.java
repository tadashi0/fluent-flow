package cn.tdx.framework.license.core.interceptor;

import cn.tdx.framework.common.exception.enums.GlobalErrorCodeConstants;
import cn.tdx.framework.common.pojo.CommonResult;
import cn.tdx.framework.common.util.servlet.ServletUtils;
import cn.tdx.framework.license.core.utils.LicenseVerify;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;


/**
 * LicenseCheckInterceptor
 *
 * @author zwj
 */
@Component
public class LicenseCheckInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        LicenseVerify licenseVerify = new LicenseVerify();
        boolean verifyResult = licenseVerify.verify();

        if (verifyResult) {
            return true;
        } else {
            ServletUtils.writeJSON(response, CommonResult.error(GlobalErrorCodeConstants.LICENSE_ERROR.getCode(),
                    GlobalErrorCodeConstants.LICENSE_ERROR.getMsg()));
            return false;
        }
    }
}
