import request from './request'

export const getProcessList = (processKey, query) => {
  return request({
    url: `process/getList/${processKey}`,
    method: 'get',
    params: query
  })
}

export const getProcessInfo = (processKey) => {
  return request({
    url: `process/${processKey}`,
    method: 'get'
  })
}

export const createProcess = (data) => {
  return request({
    url: '/process',
    method: 'post',
    data
  })
}

export const deleteProcess = (processKey, version) => {
  return request({
    url: `/process/${processKey}`,
    method: 'delete',
    params: {version}
  })
}

/**
 * 保存流程
 */
export const saveProcess = (businessKey, data) => {
  return request({
    url: `/task/save/${businessKey}`,
    method: 'post',
    data: {
      processKey: data.processKey,
      modelContent: data.modelContent
    }
  })
}

/**
 * 启动流程
 */
export const startProcess = (businessKey, data) => {
  return request({
    url: `/task/start/${businessKey}`,
    method: 'post',
    data: {
      processKey: data.processKey,
      modelContent: data.modelContent
    }
  })
}

// 根据instanceId获取可回退节点列表
export const getBackList = (businessKey) => {
  return request({
    url: `/task/getBackList/${businessKey}`,
    method: 'get'
  })
}

// 根据businessKey获取历史流程实例模型
export const getInstanceModel = (businessKey) => {
  return request({
    url: `/task/${businessKey}`,
    method: 'get'
  })
}

// 根据businessKey获取流程状态
export const getInstanceInfo = (businessKey) => {
  return request({
    url: `/task/getInstanceInfo/${businessKey}`,
    method: 'get'
  })
}

// 根据businessKey获取流程任务列表
export const getTaskList = (businessKey) => {
  return request({
    url: `/task/getTaskList/${businessKey}`,
    method: 'get'
  })
}

// 根据businessKey撤销流程实例
export const revokeProcess = (businessKey) => {
  return request({
    url: `/task/revoke/${businessKey}`,
    method: 'put'
  })
}

// 根据businessKey审批流程实例
export const approveProcess = (businessKey, data) => {
  return request({
    url: `/task/approve/${businessKey}`,
    method: 'put',
    data
  })
}

// 根据businessKey驳回至上一步处理人
export const rejectProcess = (businessKey, data) => {
  return request({
    url: `/task/reject/${businessKey}`,
    method: 'put',
    data
  })
}

// 根据businessKey驳回终止流程
export const terminateProcess = (businessKey, data) => {
  return request({
    url: `/task/terminate/${businessKey}`,
    method: 'put',
    data
  })
}

// 根据businessKey和taskKey回退流程
export const reclaimProcess = (businessKey, taskKey) => {
  return request({
    url: `/task/reclaim/${businessKey}`,
    method: 'put',
    data: {
      taskKey
    }
  })
}

// 根据businessKey和转交人转交任务
export const transferProcess = (businessKey, data) => {
  return request({
    url: `/task/transfer/${businessKey}`,
    method: 'put',
    data
  })
}

// 任务统计
export const taskCount = () => {
  return request({
    url: '/task/count',
    method: 'get'
  })
}

// 待我处理
export const todoList = (query) => {
  return request({
    url: '/task/todoList',
    method: 'get',
    params: query
  })
}

// 已办任务
export const doneList = (query) => {
  return request({
    url: '/task/doneList',
    method: 'get',
    params: query
  })
}

// 我发起的
export const submitList = (isAll, query) => {
  return request({
    url: `/task/submitList/${isAll || false}`,
    method: 'get',
    params: query
  })
}

// 抄送我的
export const aboutList = (query) => {
  return request({
    url: '/task/aboutList',
    method: 'get',
    params: query
  })
}