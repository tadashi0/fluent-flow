package cn.tdx.server.controller;

import cn.tdx.framework.common.pojo.CommonResult;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static cn.tdx.framework.common.exception.enums.GlobalErrorCodeConstants.NOT_IMPLEMENTED;

/**
 * 默认 Controller，解决部分 module 未开启时的 404 提示。
 * 例如说，/bpm/** 路径，工作流
 *
 * @author 安迈源码
 */
@RestController
public class DefaultController {

    @RequestMapping("/admin-api/bpm/**")
    public CommonResult<Boolean> bpm404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[工作流模块 tdx-module-bpm - 已禁用]");
    }

    @RequestMapping("/admin-api/mp/**")
    public CommonResult<Boolean> mp404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[微信公众号 tdx-module-mp - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/product/**", // 商品中心
            "/admin-api/trade/**", // 交易中心
            "/admin-api/promotion/**"})  // 营销中心
    public CommonResult<Boolean> mall404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[商城系统 tdx-module-mall - 已禁用]");
    }

    @RequestMapping("/admin-api/erp/**")
    public CommonResult<Boolean> erp404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[ERP 模块 tdx-module-erp - 已禁用]");
    }

    @RequestMapping("/admin-api/crm/**")
    public CommonResult<Boolean> crm404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[CRM 模块 tdx-module-crm - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/report/**"})
    public CommonResult<Boolean> report404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[报表模块 tdx-module-report - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/pay/**"})
    public CommonResult<Boolean> pay404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[支付模块 tdx-module-pay - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/ai/**"})
    public CommonResult<Boolean> ai404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[AI 大模型 tdx-module-ai - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/iot/**"})
    public CommonResult<Boolean> iot404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[IOT 物联网 tdx-module-iot - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/siem/**"})
    public CommonResult<Boolean> siem404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[SIEM tdx-module-siem - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/base/**"})
    public CommonResult<Boolean> base404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[BASE 基础 tdx-module-base - 已禁用]");
    }

    @RequestMapping(value = {"/admin-api/reinsurance/**"})
    public CommonResult<Boolean> importsafe404() {
        return CommonResult.error(NOT_IMPLEMENTED.getCode(),
                "[reinsurance 重保 tdx-module-reinsurance - 已禁用]");
    }

}
