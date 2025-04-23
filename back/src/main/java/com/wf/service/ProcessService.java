package com.wf.service;

import com.aizuda.bpm.engine.entity.FlwProcess;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description 
 */public interface ProcessService {

    IPage<FlwProcess> getProcessList(String processKey, String keyword, Page page);
}
