package com.wf.service.wf;

import com.aizuda.bpm.engine.entity.FlwProcess;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wf.entity.wf.FieldInfoDTO;
import com.wf.entity.wf.TableInfoDTO;

import java.util.List;

/**
 * @author chonghui. tian
 * date 2025/4/17 17:26
 * description 
 */public interface ProcessService {

    IPage<FlwProcess> getProcessList(String processKey, Integer useScope, String keyword, Page page);

    List<TableInfoDTO> getTables(String tableName);

    List<FieldInfoDTO> getFields(String tableName);
}
