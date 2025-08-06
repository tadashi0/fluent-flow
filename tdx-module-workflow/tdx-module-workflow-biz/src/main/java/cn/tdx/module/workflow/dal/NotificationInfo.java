package cn.tdx.module.workflow.dal;

import lombok.AccessLevel;
import lombok.Builder;
import lombok.Data;
import lombok.experimental.FieldDefaults;

import java.util.Map;
import java.util.Set;

/**
 * @author chonghui. tian
 * date 2025/8/5 16:45
 * description 
 */
@Data
@Builder
@FieldDefaults(level = AccessLevel.PRIVATE)
public class NotificationInfo {
    Set<Long> receiverIds;

    String templateCode;

    Map<String, Object> templateParams;
}
