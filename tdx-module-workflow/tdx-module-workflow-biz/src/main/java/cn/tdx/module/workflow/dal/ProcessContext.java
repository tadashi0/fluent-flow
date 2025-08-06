package cn.tdx.module.workflow.dal;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

/**
 * @author chonghui. tian
 * date 2025/8/5 16:45
 * description 
 */
@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class ProcessContext {

    Long instanceId;

    String businessKey;

    String tableName;

    String processKey;

    String processName;

    @Builder.Default
    Boolean isFinished = false;
}
