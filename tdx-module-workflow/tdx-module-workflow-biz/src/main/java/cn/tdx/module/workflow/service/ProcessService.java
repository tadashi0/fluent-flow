package cn.tdx.module.workflow.service;

import cn.tdx.module.workflow.dal.FieldInfoDTO;
import cn.tdx.module.workflow.dal.TableInfoDTO;
import com.aizuda.bpm.engine.entity.FlwProcess;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;

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
