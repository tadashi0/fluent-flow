package com.wf.service.impl;

import com.aizuda.bpm.engine.assist.ObjectUtils;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.aizuda.bpm.mybatisplus.mapper.FlwProcessMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.toolkit.ChainWrappers;
import com.wf.service.ProcessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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

    @Override
    public IPage<FlwProcess> getProcessList(String processKey, String keyword, Page page) {
        Long tenantId = null;
        IPage<FlwProcess> pageResult = ChainWrappers.lambdaQueryChain(processMapper)
                .like(ObjectUtils.isNotEmpty(keyword), FlwProcess::getProcessName, keyword)
                .eq(FlwProcess::getProcessKey, processKey)
                .eq(Objects.nonNull(tenantId), FlwProcess::getTenantId, tenantId)
                .orderByDesc(FlwProcess::getProcessVersion)
                .page(page);

        return pageResult;
    }
}
