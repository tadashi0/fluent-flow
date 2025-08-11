package cn.tdx.module.workflow.controller.admin;

import cn.tdx.framework.common.pojo.CommonResult;
import cn.tdx.framework.security.core.util.SecurityFrameworkUtils;
import cn.tdx.module.workflow.dal.FieldInfoDTO;
import cn.tdx.module.workflow.dal.TableInfoDTO;
import cn.tdx.module.workflow.service.ProcessService;
import com.aizuda.bpm.engine.FlowLongEngine;
import com.aizuda.bpm.engine.assist.Assert;
import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.core.FlowCreator;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.engine.model.ModelHelper;
import com.aizuda.bpm.engine.model.NodeModel;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/flow/process")
@AllArgsConstructor
@Slf4j
public class ProcessController {
    private final FlowLongEngine flowLongEngine;
    private final ProcessService processService;

    /**
     * 根据菜单标识获取流程列表
     */
    @GetMapping("getList")
    public CommonResult<IPage<FlwProcess>> getProcessList(String processKey, Integer useScope, String keyword, Page page) {
        return CommonResult.success(processService.getProcessList(processKey, useScope, keyword, page));
    }

    /**
     * 根据菜单标识获取流程信息
     */
    @GetMapping
    public CommonResult<FlwProcess> getProcess(String processKey) {
        if (ObjectUtils.isEmpty(processKey)) {
            return CommonResult.success(null);
        }
        log.info("processKey:{}", processKey);
        // 判断processKey是否是Long类型的
        if (processKey.matches("\\d+")) {
            return CommonResult.success(flowLongEngine.processService().getProcessById(Long.valueOf(processKey)));
        } else {
            return CommonResult.success(flowLongEngine.processService().getProcessByKey(null, processKey));
        }
    }

    /**
     * 创建流程
     */
    @PostMapping
    public CommonResult<Long> create(@RequestBody FlwProcess flwProcess) {
        // 检测流程
        NodeModel nodeModel = ModelHelper.buildProcessModel(flwProcess.getModelContent()).getNodeConfig();
        Assert.isFalse(ModelHelper.checkExistApprovalNode(nodeModel), "请添加审批节点");
        int checkNode = ModelHelper.checkNodeModel(nodeModel);
        Assert.isTrue(checkNode > 0, buildCheckNodeMap(checkNode));
        int checkConditionNode = ModelHelper.checkConditionNode(nodeModel);
        Assert.isTrue(checkConditionNode > 0, buildCheckConditionNodeMap(checkConditionNode));
        return CommonResult.success(flowLongEngine.processService()
                .deploy(null, flwProcess.getModelContent(), FlowCreator.of(SecurityFrameworkUtils.getLoginUserId().toString(), SecurityFrameworkUtils.getLoginUserNickname()), true, e -> {
                    e.setModelContent(flwProcess.getModelContent());
                    e.setProcessName(flwProcess.getProcessName());
                    e.setProcessType(flwProcess.getProcessType());
                    e.setUseScope(flwProcess.getUseScope());
                    e.setRemark(flwProcess.getRemark());
                }));
    }

    private String buildCheckNodeMap(int value) {
        Map<Integer, String> map = new HashMap<>();
        map.put(1, "存在重复节点KEY");
        map.put(2, "自动通过节点配置错误");
        map.put(3, "自动拒绝节点配置错误");
        map.put(4, "路由节点必须配置错误（未配置路由分支）");
        map.put(5, "子流程节点配置错误（未选择子流程）");
        map.put(6, "抄送节点配置错误（未配置处理人，且不允许抄送自选）");
        map.put(7, "指定成员审批（未配置处理人员）");
        return map.get(value);
    }

    private String buildCheckConditionNodeMap(int value) {
        Map<Integer, String> map = new HashMap<>();
        map.put(1, "存在多个条件表达式为空");
        map.put(2, "存在多个条件子节点为空");
        map.put(3, "存在条件节点KEY重复");
        return map.get(value);
    }

    /**
     * 删除流程
     */
    @DeleteMapping
    public CommonResult delete(String processKey, Integer version) {
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

    /**
     * 获取表字段
     */
    @GetMapping("fields/{tableName}")
    public CommonResult<List<FieldInfoDTO>> getFields(@PathVariable String tableName) {
        return CommonResult.success(processService.getFields(tableName));
    }

}
