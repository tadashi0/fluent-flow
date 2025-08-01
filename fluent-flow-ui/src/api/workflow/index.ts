import request from '@/config/axios'

// 获取数据库表列表
export const getTableList = (query: any) => {
  return request.get({ url: '/flow/process/tables', params: query })
}

// 获取数据库表字段列表
export const getTableFields = (tableName: string) => {
  return request.get({ url: `/flow/process/fields/${tableName}` })
}

export const getProcessList = (query: any) => {
  return request.get({ url: '/flow/process/getList', params: query })
}

export const getProcessInfo = (processKey: string) => {
  return request.get({ url: '/flow/process', params: { processKey } })
}

export const createProcess = (data: any) => {
  return request.post({ url: '/flow/process', data })
}

export const deleteProcess = (params: any) => {
  return request.delete({ url: '/flow/process', params })
}

/**
 * 保存流程
 */
export const saveProcess = (businessKey: string, data: any) => {
  return request.post({
    url: `/flow/task/save/${businessKey}`,
    data: {
      processKey: data.processKey,
      modelContent: data.modelContent
    }
  })
}

/**
 * 启动流程
 */
export const startProcess = (businessKey: string, data: any) => {
  return request.post({
    url: `/flow/task/start/${businessKey}`,
    data: {
      processKey: data.processKey,
      modelContent: data.modelContent,
      variable: data.variable || {}
    }
  })
}

// 根据instanceId获取可回退节点列表
export const getBackList = (businessKey: string) => {
  return request.get({ url: `/flow/task/getBackList/${businessKey}` })
}

// 根据businessKey和processId获取流程实例ID
export const getSubInstanceId = (getSubInstanceId: string, businessKey: string) => {
  return request.get({ url: `/flow/task/getSubInstanceId/${getSubInstanceId}`, params: { businessKey } })
}

// 根据businessKey获取历史流程实例模型
export const getInstanceModel = (businessKey: string) => {
  return request.get({ url: `/flow/task/${businessKey}` })
}

// 根据businessKey获取流程状态
export const getInstanceInfo = (businessKey: string) => {
  return request.get({ url: `/flow/task/getInstanceInfo/${businessKey}` })
}

// 根据businessKey获取流程任务列表
export const getTaskList = (businessKey: string) => {
  return request.get({ url: `/flow/task/getTaskList/${businessKey}` })
}

// 根据businessKey撤销流程实例
export const revokeProcess = (businessKey: string) => {
  return request.put({ url: `/flow/task/revoke/${businessKey}` })
}

// 根据businessKey审批流程实例
export const approveProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/approve/${businessKey}`, data })
}

// 根据businessKey驳回至上一步处理人
export const rejectProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/reject/${businessKey}`, data })
}

// 根据businessKey驳回终止流程
export const terminateProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/terminate/${businessKey}`, data })
}

// 根据businessKey和taskKey回退流程
export const reclaimProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/reclaim/${businessKey}`, data })
}

// 根据businessKey和转交人转交任务
export const transferProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/transfer/${businessKey}`, data })
}

// 根据businessKey加签任务
export const countersignProcess = (businessKey: string, data: any) => {
  return request.put({ url: `/flow/task/countersign/${businessKey}`, data })
}
    
// 待我处理数量
export const todoCount = () => {
  return request.get({ url: '/flow/task/todoCount' })
}

// 已处理数量
export const doneCount = () => {
  return request.get({ url: '/flow/task/doneCount' })
}

// 我发起的数量
export const submitCount = () => {
  return request.get({ url: '/flow/task/submitCount' })
}

// 抄送我的数量
export const aboutCount = () => {
  return request.get({ url: '/flow/task/aboutCount' })
}

// 待我处理
export const todoList = (query: any) => {
  return request.get({ url: '/flow/task/todoList', params: query })
}

// 已办任务
export const doneList = (query: any) => {
  return request.get({ url: '/flow/task/doneList', params: query })
}

// 我发起的
export const submitList = (isAll: boolean, query: any) => {
  return request.get({ url: `/flow/task/submitList/${isAll || false}`, params: query })
}

// 抄送我的
export const aboutList = (query: any) => {
  return request.get({ url: '/flow/task/aboutList', params: query })
}

// 查询流程测试分页列表
export function pageUser(query: any) {
  return request.get({
    url: '/flow/user',
    params: query
  })
}

// 查询流程测试列表
export function listUser(query: any) {
  return request.get({
    url: '/flow/user/list',
    params: query
  })
}

// 查询流程测试详细
export function getUser(id: any) {
  return request.get({
    url: '/flow/user/' + id,
  })
}

// 新增流程测试
export function addUser(data: any) {
  return request.post({
    url: '/flow/user',
    data: data
  })
}

// 批量新增流程测试
export function addUserBatch(data: any) {
  return request.post({
    url: '/flow/user/batch',
    data: data
  })
}

// 修改流程测试
export function updateUser(data: any) {
  return request.put({
    url: '/flow/user/' + data.id,
    data: data
  })
}

// 删除流程测试
export function delUser(id: any) {
  return request.delete({
    url: '/flow/user/' + id,
  })
}

// 批量删除流程测试
export function delUserBatch(ids: any) {
  return request.delete({
    url: '/flow/user/batch',
    data: ids
  })
}