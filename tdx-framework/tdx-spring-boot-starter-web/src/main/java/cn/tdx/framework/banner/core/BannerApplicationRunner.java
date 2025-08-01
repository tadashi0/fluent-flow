package cn.tdx.framework.banner.core;

import cn.hutool.core.thread.ThreadUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.util.ClassUtils;

import java.util.concurrent.TimeUnit;

/**
 * 项目启动成功后，提供文档相关的地址
 *
 * @author 嗒哒西
 */
@Slf4j
public class BannerApplicationRunner implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) {
        ThreadUtil.execute(() -> {
            ThreadUtil.sleep(1, TimeUnit.SECONDS); // 延迟 1 秒，保证输出到结尾

            // 数据报表
            if (isNotPresent("cn.tdx.module.report.framework.security.config.SecurityConfiguration")) {
                System.out.println("[报表模块 tdx-module-report - 已禁用]");
            }
            // 工作流
            if (isNotPresent("cn.tdx.module.bpm.framework.flowable.config.BpmFlowableConfiguration")) {
                System.out.println("[工作流模块 tdx-module-bpm - 已禁用]");
            }
            // 商城系统
            if (isNotPresent("cn.tdx.module.trade.framework.web.config.TradeWebConfiguration")) {
                System.out.println("[商城系统 tdx-module-mall - 已禁用]");
            }
            // ERP 系统
            if (isNotPresent("cn.tdx.module.erp.framework.web.config.ErpWebConfiguration")) {
                System.out.println("[ERP 系统 tdx-module-erp - 已禁用]");
            }
            // CRM 系统
            if (isNotPresent("cn.tdx.module.crm.framework.web.config.CrmWebConfiguration")) {
                System.out.println("[CRM 系统 tdx-module-crm - 已禁用]");
            }
            // 微信公众号
            if (isNotPresent("cn.tdx.module.mp.framework.mp.config.MpConfiguration")) {
                System.out.println("[微信公众号 tdx-module-mp - 已禁用]");
            }
            // 支付平台
            if (isNotPresent("cn.tdx.module.pay.framework.pay.config.PayConfiguration")) {
                System.out.println("[支付系统 tdx-module-pay - 已禁用]");
            }
            // AI 大模型
            if (isNotPresent("cn.tdx.module.ai.framework.web.config.AiWebConfiguration")) {
                System.out.println("[AI 大模型 tdx-module-ai - 已禁用]");
            }
            // IOT 物联网
            if (isNotPresent("cn.tdx.module.iot.framework.web.config.IotWebConfiguration")) {
                System.out.println("[IOT 物联网 tdx-module-iot - 已禁用]");
            }
            // SIEM
            if (isNotPresent("cn.tdx.module.siem.framework.web.config.SiemWebConfiguration")) {
                System.out.println("[SIEM tdx-module-siem - 已禁用]");
            }
        });
    }

    private static boolean isNotPresent(String className) {
        return !ClassUtils.isPresent(className, ClassUtils.getDefaultClassLoader());
    }

}
