package com.wf.common.exception;

import com.aizuda.bpm.engine.exception.FlowLongException;
import com.wf.common.exception.enums.GlobalErrorCodeConstants;
import com.wf.common.pojo.CommonResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import javax.servlet.http.HttpServletRequest;

/**
 * 全局异常处理器
 *
 * @author LiTao
 */
@RestControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /**
     * 请求方式不支持
     */
    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public CommonResult handleHttpRequestMethodNotSupported(HttpRequestMethodNotSupportedException e,
                                                            HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',不支持'{}'请求", requestURI, e.getMethod());
        return CommonResult.error(GlobalErrorCodeConstants.METHOD_NOT_ALLOWED, e.getMessage());
    }

    /**
     * 流程异常
     */
    @ExceptionHandler(FlowLongException.class)
    public CommonResult handleFlowLongException(FlowLongException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',发生流程异常.", requestURI, e);
        return CommonResult.error(new ErrorCode(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR.getCode(), e.getMessage()));
    }

    /**
     * 业务异常
     */
    @ExceptionHandler(ServerException.class)
    public CommonResult handleBusinessException(ServerException e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',发生业务异常.{}", requestURI, e.getMessage());
        return CommonResult.error(new ErrorCode(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR.getCode(), e.getMessage()));
    }

    /**
     * 系统异常
     */
    @ExceptionHandler(Exception.class)
    public CommonResult handleException(Exception e, HttpServletRequest request) {
        String requestURI = request.getRequestURI();
        log.error("请求地址'{}',发生系统异常.", requestURI, e);
        return CommonResult.error(new ErrorCode(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR.getCode(), "系统开小差了, 请稍后再试"));
    }



}
