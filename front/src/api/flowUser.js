import request from './request'

// 查询流程测试分页列表
export function pageUser(query) {
  return request({
    url: '/user',
    method: 'get',
    params: query
  })
}

// 查询流程测试列表
export function listUser(query) {
  return request({
    url: '/user/list',
    method: 'get',
    params: query
  })
}

// 查询流程测试详细
export function getUser(id) {
  return request({
    url: '/user/' + id,
    method: 'get'
  })
}

// 新增流程测试
export function addUser(data) {
  return request({
    url: '/user',
    method: 'post',
    data: data
  })
}

// 批量新增流程测试
export function addUserBatch(data) {
  return request({
    url: '/user/batch',
    method: 'post',
    data: data
  })
}

// 修改流程测试
export function updateUser(data) {
  return request({
    url: '/user/' + data.id,
    method: 'put',
    data: data
  })
}

// 删除流程测试
export function delUser(id) {
  return request({
    url: '/user/' + id,
    method: 'delete'
  })
}

// 批量删除流程测试
export function delUserBatch(ids) {
  return request({
    url: '/user/batch',
    method: 'delete',
    data: ids
  })
}
