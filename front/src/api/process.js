import request from './request'

export const getProcessList = (processKey) => {
  return request({
    url: `process/getList/${processKey}`,
    method: 'get'
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

export const disableProcess = (id) => {
  return request({
    url: `/process/${id}`,
    method: 'put'
  })
}

export const deleteProcess = (id) => {
  return request({
    url: `/process/${id}`,
    method: 'delete'
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
      modelContent: JSON.stringify(data.flowData)
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
      modelContent: JSON.stringify(data.flowData)
    }
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
export const getProcessState = (businessKey) => {
  return request({
    url: `/task/getProcessState/${businessKey}`,
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

// 根据任务ID和节点key回退流程
export const reclaimProcess = (taskId, taskKey) => {
  return request({
    url: `/task/reclaim/${taskId}`,
    method: 'put',
    data: {
      taskKey
    }
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
export const todoList = () => {
  return request({
    url: '/task/todoList',
    method: 'get'
  })
}

// 已办任务
export const doneList = () => {
  return request({
    url: '/task/doneList',
    method: 'get'
  })
}

// 我发起的
export const submitList = () => {
  return request({
    url: '/task/submitList',
    method: 'get'
  })
}

// 抄送我的
export const aboutList = () => {
  return request({
    url: '/task/aboutList',
    method: 'get'
  })
}