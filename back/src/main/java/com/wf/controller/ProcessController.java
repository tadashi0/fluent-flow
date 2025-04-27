package com.wf.controller;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.common.exception.ServiceException;
import com.wf.common.pojo.CommonResult;
import com.wf.entity.TableInfoDTO;
import com.wf.service.ProcessService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/process")
@AllArgsConstructor
@Slf4j
public class ProcessController {
    private final static FlowCreator testCreator = FlowCreator.of("20240815", "田重辉");
    private final  FlowLongEngine flowLongEngine;
    private final ProcessService processService;

    /**
     * 根据菜单标识获取流程列表
     */
    @GetMapping("getList")
    public CommonResult<IPage<FlwProcess>> getProcessList(String processKey, String keyword, Page page) {
        return CommonResult.success(processService.getProcessList(processKey, keyword, page));
    }

    /**
     * 根据菜单标识获取流程信息
     */
    @GetMapping
    public CommonResult<FlwProcess> getProcess(String processKey) {
        log.info("processKey:{}", processKey);
        return CommonResult.success(Optional.ofNullable(flowLongEngine.processService()
                .getProcessByKey(null, processKey))
                .orElseThrow(() -> new ServiceException("流程不存在")));
    }

    /**
     * 创建流程
     */
    @PostMapping
    public CommonResult<Long> create(@RequestBody FlwProcess flwProcess) {
        return CommonResult.success(flowLongEngine.processService()
                .deploy(null, flwProcess.getModelContent(), testCreator, true, e -> {
                    e.setModelContent(flwProcess.getModelContent());
                    e.setProcessName(flwProcess.getProcessName());
                    e.setProcessType(flwProcess.getProcessType());
                    e.setRemark(flwProcess.getRemark());
                }));
    }

    /**
     * 删除流程
     */
    @DeleteMapping("{processKey}")
    public CommonResult delete(@PathVariable String processKey, Integer version) {
        FlwProcess flwProcess = flowLongEngine.processService().getProcessByVersion(null, processKey, version);
        flowLongEngine.processService().cascadeRemove(flwProcess.getId());
        return CommonResult.success(true);
    }

    /**
     * 获取数据库表
     */
    @GetMapping("tables")
    public CommonResult<List<TableInfoDTO>> getTables(@RequestParam(required = false) String tableName) {
        return CommonResult.success(processService.getTables(tableName));
    }

}
