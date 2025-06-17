package com.wf.service.impl;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.mybatisplus.mapper.FlwProcessMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.wf.entity.FieldInfoDTO;
import com.wf.entity.TableInfoDTO;
import com.wf.mapper.ProcessMapper;
import com.wf.service.ProcessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ProcessServiceImpl implements ProcessService {

    private final FlwProcessMapper processMapper;
    private final ProcessMapper mapper;

    @Override
    public IPage<FlwProcess> getProcessList(String processKey, Integer useScope, String keyword, Page page) {
        Long tenantId = null;
        IPage<FlwProcess> pageResult = ChainWrappers.lambdaQueryChain(processMapper)
                .eq(ObjectUtils.isNotEmpty(useScope), FlwProcess::getUseScope, useScope)
                .like(ObjectUtils.isNotEmpty(processKey), FlwProcess::getProcessKey, processKey)
                .like(ObjectUtils.isNotEmpty(keyword), FlwProcess::getProcessName, keyword)
                .eq(ObjectUtils.isNotEmpty(useScope), FlwProcess::getProcessState, 1)
                .eq(Objects.nonNull(tenantId), FlwProcess::getTenantId, tenantId)
                .orderByAsc(FlwProcess::getProcessState)
                .orderByAsc(FlwProcess::getUseScope)
                .orderByDesc(FlwProcess::getCreateTime)
                .page(page);

        return pageResult;
    }

    @Override
    public List<TableInfoDTO> getTables(String tableName) {
        return mapper.getTableInfoList(tableName);
    }

    @Override
    public List<FieldInfoDTO> getFields(String tableName) {
        return mapper.getFieldInfoList(tableName);
    }
}
