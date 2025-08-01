package cn.tdx.module.system.api.dept;

import java.util.Collection;
import java.util.List;

import org.springframework.stereotype.Service;

import cn.tdx.framework.common.util.object.BeanUtils;
import cn.tdx.module.system.api.dept.dto.DeptRespDTO;
import cn.tdx.module.system.controller.admin.dept.vo.dept.DeptListReqVO;
import cn.tdx.module.system.dal.dataobject.dept.DeptDO;
import cn.tdx.module.system.service.dept.DeptService;
import jakarta.annotation.Resource;

/**
 * 部门 API 实现类
 *
 * @author 安迈源码
 */
@Service
public class DeptApiImpl implements DeptApi {

    @Resource
    private DeptService deptService;

    @Override
    public DeptRespDTO getDept(Long id) {
        DeptDO dept = deptService.getDept(id);
        return BeanUtils.toBean(dept, DeptRespDTO.class);
    }

    @Override
    public List<DeptRespDTO> getDeptList(Collection<Long> ids) {
        List<DeptDO> depts = deptService.getDeptList(ids);
        return BeanUtils.toBean(depts, DeptRespDTO.class);
    }

    @Override
    public List<DeptRespDTO> getAllDeptList() {
        List<DeptDO> deptList = deptService.getDeptList(new DeptListReqVO());
        return BeanUtils.toBean(deptList, DeptRespDTO.class);
    }

    @Override
    public void validateDeptList(Collection<Long> ids) {
        deptService.validateDeptList(ids);
    }

    @Override
    public List<DeptRespDTO> getChildDeptList(Long id) {
        List<DeptDO> childDeptList = deptService.getChildDeptList(id);
        return BeanUtils.toBean(childDeptList, DeptRespDTO.class);
    }

    @Override
    public DeptRespDTO getDeptByName(String name) {
        DeptDO dept = deptService.getDeptByName(name);
        return BeanUtils.toBean(dept, DeptRespDTO.class);
    }

    @Override
    public List<DeptRespDTO> getDeptList() {
        List<DeptDO> deptList = deptService.getDeptList(new DeptListReqVO());
        return BeanUtils.toBean(deptList, DeptRespDTO.class);
    }
}
