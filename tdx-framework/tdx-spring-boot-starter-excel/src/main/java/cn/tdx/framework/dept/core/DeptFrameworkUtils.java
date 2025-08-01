package cn.tdx.framework.dept.core;

import java.time.Duration;
import java.util.List;

import cn.tdx.framework.common.util.cache.CacheUtils;
import cn.tdx.module.system.api.dept.DeptApi;
import cn.tdx.module.system.api.dept.dto.DeptRespDTO;
import com.google.common.cache.CacheLoader;
import com.google.common.cache.LoadingCache;

import cn.hutool.core.util.ObjectUtil;
import lombok.SneakyThrows;
import lombok.extern.slf4j.Slf4j;

/**
 * 部门工具类
 *
 * @author 芋道源码
 */
@Slf4j
public class DeptFrameworkUtils {

    private static DeptApi deptApi;

    private static final DeptRespDTO DEPT_DATA_NULL = new DeptRespDTO();

    /**
     * 针对 {@link #getDeptData(String)} 的缓存
     */
    private static final LoadingCache<String, DeptRespDTO> GET_DEPT_DATA_CACHE = CacheUtils.buildAsyncReloadingCache(Duration.ofMinutes(1L), // 过期时间 1 分钟
            new CacheLoader<String, DeptRespDTO>() {

                @Override
                public DeptRespDTO load(String key) {
                    return ObjectUtil.defaultIfNull(deptApi.getDeptByName(key), DEPT_DATA_NULL);
                }

            });


    public static void init(DeptApi deptApi) {
        DeptFrameworkUtils.deptApi = deptApi;
        log.info("[init][初始化 DeptFrameworkUtils 成功]");
    }

    @SneakyThrows
    public static DeptRespDTO getDeptData(String deptName) {
        return GET_DEPT_DATA_CACHE.get(deptName);
    }

    @SneakyThrows
    public static List<DeptRespDTO> getDeptList() {
        return deptApi.getDeptList();
    }
}
