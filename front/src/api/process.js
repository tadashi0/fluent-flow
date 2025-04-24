import request from './request'

// 获取数据库表列表
export const getTableList = (query) => {
  return request.get('/process/tables', {params: query})
}

export const getProcessList = (processKey, query) => {
  return request.get(`process/getList/${processKey}`, {params: query})
}

export const getProcessInfo = (processKey) => {
  return request.get(`process/${processKey}`)
}

export const createProcess = (data) => {
  return request.post('/process', data)
}

export const deleteProcess = (processKey, version) => {
  return request.delete(`/process/${processKey}`, {params: {version}})
}

/**
 * 保存流程
 */
export const saveProcess = (businessKey, data) => {
  return request.post(`/task/save/${businessKey}`, {
    processKey: data.processKey,
    modelContent: data.modelContent
  })
}

/**
 * 启动流程
 */
export const startProcess = (businessKey, data) => {
  return request.post(`/task/start/${businessKey}`, {
    processKey: data.processKey,
    modelContent: data.modelContent
  })
}

// 根据instanceId获取可回退节点列表
export const getBackList = (businessKey) => {
  return request.get(`/task/getBackList/${businessKey}`)
}

// 根据businessKey获取历史流程实例模型
export const getInstanceModel = (businessKey) => {
  return request.get(`/task/${businessKey}`)
}

// 根据businessKey获取流程状态
export const getInstanceInfo = (businessKey) => {
  return request.get(`/task/getInstanceInfo/${businessKey}`)
}

// 根据businessKey获取流程任务列表
export const getTaskList = (businessKey) => {
  return request.get(`/task/getTaskList/${businessKey}`)
}

// 根据businessKey撤销流程实例
export const revokeProcess = (businessKey) => {
  return request.put(`/task/revoke/${businessKey}`)
}

// 根据businessKey审批流程实例
export const approveProcess = (businessKey, data) => {
  return request.put(`/task/approve/${businessKey}`, data)
}

// 根据businessKey驳回至上一步处理人
export const rejectProcess = (businessKey, data) => {
  return request.put(`/task/reject/${businessKey}`, data)
}

// 根据businessKey驳回终止流程
export const terminateProcess = (businessKey, data) => {
  return request.put(`/task/terminate/${businessKey}`, data)
}

// 根据businessKey和taskKey回退流程
export const reclaimProcess = (businessKey, taskKey) => {
  return request.put(`/task/reclaim/${businessKey}`, {
    taskKey
  })
}

// 根据businessKey和转交人转交任务
export const transferProcess = (businessKey, data) => {
  return request.put(`/task/transfer/${businessKey}`, data)
}

// 任务统计
export const taskCount = () => {
  return request.get('/task/count')
}

// 待我处理
export const todoList = (query) => {
  return request.get('/task/todoList', {params: query})
}

// 已办任务
export const doneList = (query) => {
  return request.get('/task/doneList', {params: query})
}

// 我发起的
export const submitList = (isAll, query) => {
  return request.get(`/task/submitList/${isAll || false}`, {params: query})
}

// 抄送我的
export const aboutList = (query) => {
  return request.get('/task/aboutList', {params: query})
}