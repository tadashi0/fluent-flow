package cn.tdx.module.workflow.controller.admin;

import cn.tdx.framework.common.exception.enums.GlobalErrorCodeConstants;
import cn.tdx.framework.common.pojo.CommonResult;
import cn.tdx.module.workflow.dal.FlowUser;
import cn.tdx.module.workflow.service.FlowUserService;
import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

/**
 * 流程测试Controller
 *
 * @author chonghui.tian
 * @date 2025-04-22
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("flow/user")
public class FlowUserController {

    private final FlowUserService flowUserService;

    /**
     * 创建FlowUser
     *
     * @param flowUser A new FlowUser to create
     * @return The id of the {@link FlowUser} that was just created
     */
    @PostMapping
    public CommonResult createFlowUser(@RequestBody @Validated FlowUser flowUser) {
        return flowUserService.createFlowUser(flowUser)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"新建失败, 请稍后重试!"));
    }

    /**
     * 批量创建FlowUser
     *
     * @param flowUsers multiple FlowUser to create
     * @return The result of whether to create successfully
     */
    @PostMapping("/batch")
    public CommonResult createFlowUserBatch(@RequestBody @Validated List<FlowUser> flowUsers) {
        return flowUserService.createFlowUserBatch(flowUsers)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"批量新建失败, 请稍后重试!"));
    }

    /**
     * 编辑FlowUser
     *
     * @param id The ID of the FlowUser to update
     * @param latest The specified FlowUser that need to be updated
     * @return The result of whether to update successfully
     */
    @PutMapping("/{id}")
    public CommonResult modifyFlowUser(@PathVariable("id") Long id, @RequestBody @Validated FlowUser latest) {
        latest.setId(id);
        return flowUserService.modifyFlowUser(id, latest)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"更新失败, 请稍后重试!"));
    }

    /**
     * 删除FlowUser
     *
     * @param id The ID of the {@link FlowUser} to delete
     * @return The result of whether to delete successfully
     */
    @DeleteMapping("/{id}")
    public CommonResult deleteFlowUser(@PathVariable("id") Long id) {
        return flowUserService.deleteFlowUser(id)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"删除失败, 请稍后重试!"));
    }

    /**
     * 批量删除FlowUser
     *
     * @param ids The list of IDs to delete
     * @return The result of whether to delete successfully
     */
    @DeleteMapping("/batch")
    public CommonResult deleteFlowUserBatch(@RequestBody Set<Long> ids) {
        return flowUserService.deleteFlowUserBatch(ids)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"删除失败, 请稍后重试!"));
    }

    /**
     * 获取FlowUser详情
     *
     * @param id The ID of the specified FlowUser
     * @return An instance of {@link FlowUser}
     */
    @GetMapping("/{id}")
    public CommonResult getFlowUserDetailById(@PathVariable("id") Long id) {
        return flowUserService.getFlowUserDetailById(id)
                .map(CommonResult::success)
                .orElseGet(() -> CommonResult.error(GlobalErrorCodeConstants.INTERNAL_SERVER_ERROR,"查询失败, 请稍后重试!"));
    }

    /**
     * 分页获取FlowUser列表
     *
     * @param flowUser the query parameters
     * @return Paginated list of FlowUsers
     */
    @GetMapping
    public CommonResult pageFlowUser(FlowUser flowUser) {
        IPage<FlowUser> flowUserIPage = flowUserService.pageFlowUser(flowUser);
        return CommonResult.success(flowUserIPage);
    }

    /**
     * 获取FlowUser列表
     *
     * @param flowUser the query parameters
     * @return A list of FlowUsers
     */
    @GetMapping("/list")
    public CommonResult listFlowUser(FlowUser flowUser) {
        List<FlowUser> flowUserList = flowUserService.listFlowUser(flowUser);
        return CommonResult.success(flowUserList);
    }
}
