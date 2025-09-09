import { store } from '../../index'
import { defineStore } from 'pinia'
import type {
  ProcessModel,
  ProcessInstanceInfo,
  TaskInfo,
  WorkflowNode,
  NodeConfigForm,
  UserInfo,
  ProcessButtonConfig
} from '@/components/WorkFlow/types'
import { ProcessState, NodeType } from '@/components/WorkFlow/constants'
import { ProcessApi, ProcessInstanceApi, TaskApi, TaskQueryApi } from '@/components/WorkFlow/api/workflowApi'

interface WorkFlowState {
  // 流程设计相关
  currentProcess: ProcessModel | null
  processHistory: ProcessModel[]

  // 流程实例相关
  currentInstance: ProcessInstanceInfo | null
  instanceTasks: TaskInfo[]

  // 节点配置相关
  selectedNode: WorkflowNode | null
  nodeConfigForm: NodeConfigForm | null

  // UI状态
  drawerStates: {
    promoter: boolean
    approver: boolean
    copyer: boolean
    condition: boolean
    nodeConfig: boolean
  }

  // 用户选择相关
  selectedUsers: UserInfo[]
  selectedRoles: any[]
  selectedDepts: any[]

  // 缓存相关
  processCache: Map<string, ProcessModel>
  instanceCache: Map<string, ProcessInstanceInfo>

  // 统计数据
  taskCounts: {
    todo: number
    done: number
    submit: number
    about: number
  }

  // 加载状态
  loading: {
    process: boolean
    instance: boolean
    tasks: boolean
    approval: boolean
  }
}

export const useWorkFlowStore = defineStore('workflow', {
  state: (): WorkFlowState => ({
    // 流程设计相关
    currentProcess: null,
    processHistory: [],

    // 流程实例相关
    currentInstance: null,
    instanceTasks: [],

    // 节点配置相关
    selectedNode: null,
    nodeConfigForm: null,

    // UI状态
    drawerStates: {
      promoter: false,
      approver: false,
      copyer: false,
      condition: false,
      nodeConfig: false
    },

    // 用户选择相关
    selectedUsers: [],
    selectedRoles: [],
    selectedDepts: [],

    // 缓存相关
    processCache: new Map(),
    instanceCache: new Map(),

    // 统计数据
    taskCounts: {
      todo: 0,
      done: 0,
      submit: 0,
      about: 0
    },

    // 加载状态
    loading: {
      process: false,
      instance: false,
      tasks: false,
      approval: false
    }
  }),

  getters: {
    // 获取当前流程状态
    currentProcessState: (state) => {
      return state.currentInstance?.taskState || ProcessState.PENDING
    },

    // 获取当前节点
    currentNode: (state) => {
      return state.selectedNode
    },

    // 获取流程是否可编辑
    isProcessEditable: (state) => {
      const processState = state.currentInstance?.taskState
      return !processState || processState === ProcessState.PENDING
    },

    // 获取待办任务数量
    todoTaskCount: (state) => state.taskCounts.todo,

    // 获取是否有加载中的操作
    hasLoading: (state) => {
      return Object.values(state.loading).some(loading => loading)
    },

    // 获取流程节点统计
    processNodeStats: (state) => {
      if (!state.currentProcess?.nodeConfig) return null

      const stats = {
        total: 0,
        approver: 0,
        cc: 0,
        condition: 0,
        subProcess: 0
      }

      const countNodes = (node: WorkflowNode) => {
        if (!node) return

        stats.total++

        switch (node.type) {
          case NodeType.APPROVER:
            stats.approver++
            break
          case NodeType.CC:
            stats.cc++
            break
          case NodeType.CONDITION:
            stats.condition++
            break
          case NodeType.SUB_PROCESS:
            stats.subProcess++
            break
        }

        // 递归统计子节点
        if (node.childNode) {
          countNodes(node.childNode)
        }

        // 统计分支节点
        if ('conditionNodes' in node && node.conditionNodes) {
          node.conditionNodes.forEach(countNodes)
        }
        if ('parallelNodes' in node && node.parallelNodes) {
          node.parallelNodes.forEach(countNodes)
        }
      }

      countNodes(state.currentProcess.nodeConfig)
      return stats
    }
  },

  actions: {
    // ==================== 流程管理 ====================

    /**
     * 设置当前流程
     */
    setCurrentProcess(process: ProcessModel | null) {
      this.currentProcess = process
      if (process) {
        this.processCache.set(process.key, process)
        // 添加到历史记录
        const existingIndex = this.processHistory.findIndex(p => p.key === process.key)
        if (existingIndex >= 0) {
          this.processHistory.splice(existingIndex, 1)
        }
        this.processHistory.unshift(process)
        // 限制历史记录数量
        if (this.processHistory.length > 10) {
          this.processHistory = this.processHistory.slice(0, 10)
        }
      }
    },

    /**
     * 加载流程信息
     */
    async loadProcess(processKey: string) {
      // 先从缓存获取
      const cached = this.processCache.get(processKey)
      if (cached) {
        this.setCurrentProcess(cached)
        return cached
      }

      this.loading.process = true
      try {
        const process = await ProcessApi.getProcessInfo(processKey)
        this.setCurrentProcess(process)
        return process
      } finally {
        this.loading.process = false
      }
    },

    /**
     * 保存流程
     */
    async saveProcess(processData: Partial<ProcessModel>) {
      this.loading.process = true
      try {
        let result: ProcessModel
        if (processData.key && this.processCache.has(processData.key)) {
          result = await ProcessApi.updateProcess(processData)
        } else {
          result = await ProcessApi.createProcess(processData)
        }
        this.setCurrentProcess(result)
        return result
      } finally {
        this.loading.process = false
      }
    },

    // ==================== 流程实例管理 ====================

    /**
     * 设置当前实例
     */
    setCurrentInstance(instance: ProcessInstanceInfo | null) {
      this.currentInstance = instance
      if (instance) {
        this.instanceCache.set(instance.businessKey, instance)
      }
    },

    /**
     * 加载流程实例
     */
    async loadInstance(businessKey: string) {
      // 先从缓存获取
      const cached = this.instanceCache.get(businessKey)
      if (cached) {
        this.setCurrentInstance(cached)
        return cached
      }

      this.loading.instance = true
      try {
        const instance = await ProcessInstanceApi.getInstanceInfo(businessKey)
        this.setCurrentInstance(instance)
        return instance
      } finally {
        this.loading.instance = false
      }
    },

    /**
     * 启动流程实例
     */
    async startInstance(businessKey: string, data: any) {
      this.loading.instance = true
      try {
        const instance = await ProcessInstanceApi.startProcess(businessKey, data)
        this.setCurrentInstance(instance)
        return instance
      } finally {
        this.loading.instance = false
      }
    },

    // ==================== 任务管理 ====================

    /**
     * 加载任务列表
     */
    async loadTasks(businessKey: string) {
      this.loading.tasks = true
      try {
        const tasks = await TaskApi.getTaskList(businessKey)
        this.instanceTasks = tasks
        return tasks
      } finally {
        this.loading.tasks = false
      }
    },

    /**
     * 执行审批操作
     */
    async executeApproval(businessKey: string, action: string, data: any) {
      this.loading.approval = true
      try {
        switch (action) {
          case 'approve':
            await TaskApi.approveProcess(businessKey, data)
            break
          case 'reject':
            await TaskApi.rejectProcess(businessKey, data)
            break
          case 'transfer':
            await TaskApi.transferProcess(businessKey, data)
            break
          case 'reclaim':
            await TaskApi.reclaimProcess(businessKey, data)
            break
          case 'terminate':
            await TaskApi.terminateProcess(businessKey, data)
            break
          case 'countersign':
            await TaskApi.countersignProcess(businessKey, data)
            break
          default:
            throw new Error(`未知的审批操作: ${action}`)
        }

        // 刷新实例和任务数据
        await Promise.all([
          this.loadInstance(businessKey),
          this.loadTasks(businessKey),
          this.refreshTaskCounts()
        ])
      } finally {
        this.loading.approval = false
      }
    },

    // ==================== 统计数据 ====================

    /**
     * 刷新任务统计数据
     */
    async refreshTaskCounts() {
      try {
        const [todo, done, submit, about] = await Promise.all([
          TaskQueryApi.getTodoCount(),
          TaskQueryApi.getDoneCount(),
          TaskQueryApi.getSubmitCount(),
          TaskQueryApi.getAboutCount()
        ])

        this.taskCounts = { todo, done, submit, about }
      } catch (error) {
        console.error('刷新任务统计失败:', error)
      }
    },

    // ==================== 节点配置 ====================

    /**
     * 选择节点
     */
    selectNode(node: WorkflowNode | null) {
      this.selectedNode = node
      if (node) {
        // 初始化节点配置表单
        this.nodeConfigForm = {
          nodeName: node.nodeName,
          // 其他配置项...
        }
      } else {
        this.nodeConfigForm = null
      }
    },

    /**
     * 更新节点配置
     */
    updateNodeConfig(config: Partial<NodeConfigForm>) {
      if (this.nodeConfigForm) {
        Object.assign(this.nodeConfigForm, config)
      }
    },

    // ==================== UI状态管理 ====================

    /**
     * 设置抽屉状态
     */
    setDrawerState(drawer: keyof WorkFlowState['drawerStates'], visible: boolean) {
      this.drawerStates[drawer] = visible
    },

    /**
     * 关闭所有抽屉
     */
    closeAllDrawers() {
      Object.keys(this.drawerStates).forEach(key => {
        this.drawerStates[key as keyof WorkFlowState['drawerStates']] = false
      })
    },

    // ==================== 用户选择 ====================

    /**
     * 设置选中的用户
     */
    setSelectedUsers(users: UserInfo[]) {
      this.selectedUsers = users
    },

    /**
     * 添加选中用户
     */
    addSelectedUser(user: UserInfo) {
      const exists = this.selectedUsers.find(u => u.id === user.id)
      if (!exists) {
        this.selectedUsers.push(user)
      }
    },

    /**
     * 移除选中用户
     */
    removeSelectedUser(userId: string | number) {
      const index = this.selectedUsers.findIndex(u => u.id === userId)
      if (index >= 0) {
        this.selectedUsers.splice(index, 1)
      }
    },

    // ==================== 缓存管理 ====================

    /**
     * 清除缓存
     */
    clearCache() {
      this.processCache.clear()
      this.instanceCache.clear()
    },

    /**
     * 清除指定流程的缓存
     */
    clearProcessCache(processKey: string) {
      this.processCache.delete(processKey)
    },

    /**
     * 重置状态
     */
    resetState() {
      this.currentProcess = null
      this.currentInstance = null
      this.instanceTasks = []
      this.selectedNode = null
      this.nodeConfigForm = null
      this.selectedUsers = []
      this.selectedRoles = []
      this.selectedDepts = []
      this.closeAllDrawers()
    }
  }
})

export const useWorkFlowStoreWithOut = () => {
  return useWorkFlowStore(store)
}
