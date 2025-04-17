package com.example.demo.controller;

import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.entity.FlwInstance;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.example.demo.common.exception.ServiceException;
import com.example.demo.common.pojo.CommonResult;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/process")
@AllArgsConstructor
@Slf4j
public class ProcessController {
    protected static FlowCreator testCreator = FlowCreator.of("20240815", "田重辉");
    protected FlowLongEngine flowLongEngine;

    /**
     * <a href="http://localhost:8000/process/deploy">流程部署</a>
     */
    @GetMapping("/deploy")
    public Long deployByResource() {
        return flowLongEngine.processService().deployByResource("process.json", testCreator, false);
    }

    /**
     * <a href="http://localhost:8000/process/instance-start">启动流程实例</a>
     */
    @GetMapping("/instance-start")
    public FlwInstance instanceStart() {
        Map<String, Object> args = new HashMap<>();
        args.put("day", 8);
        args.put("assignee", "test001");
        return flowLongEngine.startInstanceByProcessKey("process", null, testCreator, args).get();
    }


    /**
     * 根据菜单标识获取流程列表
     */
    @GetMapping("getList/{processKey}")
    public CommonResult<List<FlwProcess>> getProcessList(@PathVariable String processKey) {
        log.info("processKey:{}", processKey);
        return CommonResult.success(Arrays.asList(flowLongEngine.processService()
                .getProcessByKey(null, processKey)));
    }

    /**
     * 根据菜单标识获取流程信息
     */
    @GetMapping("{processKey}")
    public CommonResult<FlwProcess> getProcess(@PathVariable String processKey) {
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
                    e.setRemark(flwProcess.getRemark());
                }));
    }

    /**
     * 禁用流程
     */
    @PutMapping("/{id}")
    public CommonResult<Boolean> undeploy(@PathVariable Long id) {
        return CommonResult.success(flowLongEngine.processService()
                        .undeploy(id));
    }

    /**
     * 删除流程
     */
    @DeleteMapping("/{id}")
    public CommonResult delete(@PathVariable Long id) {
        flowLongEngine.processService().cascadeRemove(id);
        return CommonResult.success(true);
    }

}
