<template>
<div class="workflow-container">
  <!-- 发起人节点 -->
  <div v-if="node.type === 0" class="workflow-item">
    <div class="workflow-icon">
      <!-- <span>发</span>
      <div v-if="node.taskState !== undefined" class="status-indicator" :class="getStatusIndicatorClass(node)"></div> -->
      <span>{{ node.nodeAssigneeList?.[0].name?.substring(0, 1) || '发' }}</span>
      <div v-if="node.taskState !== undefined" class="status-indicator" :class="getStatusIndicatorClass(node)"></div>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '发起人' }}</div>
      <div class="workflow-desc">
        {{ formatAssignees(node.nodeAssigneeList) || '发起人自己' }}
      </div>
      <!-- 任务历史记录 -->
      <div v-if="node.taskList && node.taskList.length > 0" class="task-history">
        <div v-for="(task, index) in node.taskList" :key="index" class="task-history-item">
          <div class="task-history-avatar">
            <span>{{ task?.assignor?.substring(0, 1) || 'a' }}</span>
            <div class="status-indicator" :class="getStatusIndicatorClass({taskState: task.taskState})"></div>
          </div>
          <div class="task-history-content">
            <div class="task-history-header">
              <span class="task-history-user">{{ task?.assignor || 'admin' }}</span>
              <span class="task-history-time">{{ getStartNodeStateText({taskState: task.taskState}) }} {{ formatTime(task.finishTime) }}</span>
            </div>
            <div v-if="task.duration" class="task-history-duration">
              处理耗时: {{ formatDuration(task.duration) }}
            </div>
            <div v-if="task.variable" class="task-history-comment">
              {{ JSON.parse(task.variable)?.comment || '' }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 审批人节点 -->
  <div v-else-if="node.type === 1" class="workflow-item">
    <div class="workflow-icon">
      <!-- <span>审</span> -->
      <span>{{ node.nodeAssigneeList?.[0]?.name?.substring(0, 1) || node.nodeName?.substring(0, 1) }}</span>
      <div v-if="node.taskState !== undefined" class="status-indicator" :class="getStatusIndicatorClass(node)"></div>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '审批人' }} <span v-if="node.taskState !== undefined" class="state-tag">{{ getNodeStateText(node) }}</span></div>
      <div class="workflow-desc">
        <div>{{ getApproveTypeText(node.setType) }}</div>
        <div v-if="node.examineMode">{{ getExamineModeText(node.examineMode) }}</div>
        <div v-if="showAssignees(node)">
          {{ formatAssignees(node.nodeAssigneeList)}}
        </div>
        <div v-if="node.nodeCandidate && node.nodeCandidate.assignees?.length">
          {{ getCandidateTypeText(node.nodeCandidate.type) }}：
          {{ formatAssignees(node.nodeCandidate.assignees) }}
        </div>
        <div v-if="node.setType === 2 || node.setType === 6">
          {{ getLevelText(node) }}
        </div>
        <div v-if="node.examineMode === 4 && node.passWeight">
          通过权重: {{ node.passWeight }}%
        </div>
        <div v-if="node.term">
          审批期限: {{ node.term }}小时
          <span v-if="node.termAuto">
            (超时{{ node.termMode === 0 ? '自动通过' : '自动拒绝' }})
          </span>
        </div>
      </div>
      
      <!-- 任务历史记录 -->
      <div v-if="node.taskList && node.taskList.length > 0" class="task-history">
        <div v-for="(task, index) in node.taskList" :key="index" class="task-history-item">
          <div class="task-history-avatar">
            <span>{{ task?.assignor?.substring(0, 1) || 'a' }}</span>
            <div class="status-indicator" :class="getStatusIndicatorClass({taskState: task.taskState})"></div>
          </div>
          <div class="task-history-content">
            <div class="task-history-header">
              <span class="task-history-user">{{ task?.assignor || 'admin' }}</span>
              <span class="task-history-time">{{ getNodeStateText({taskState: task.taskState}) }} {{ formatTime(task.finishTime) }}</span>
            </div>
            <div v-if="task.duration" class="task-history-duration">
              处理耗时: {{ formatDuration(task.duration) }}
            </div>
            <div v-if="task.variable && task.taskState !== 0" class="task-history-comment">
              {{ JSON.parse(task.variable)?.comment || '' }}
            </div>
            <div v-if="task.expireTime" class="task-history-expire">
              期望完成时间: {{ formatTime(task.expireTime) }}
            </div>
            <div v-if="task.nodeTransfer" class="task-history-transfer">
              {{ task.nodeTransfer }}
            </div>
          </div>
        </div>
      </div>
    </div>
    <!-- 编辑模式下的添加按钮 -->
    <div v-if="mode === 'edit' && node.setType === 4" 
       class="edit-add-btn"
       @click="handleAddCandidate">
      <div class="add-icon">+</div>
    </div>
  </div>

    <!-- 抄送人节点 -->
  <div v-else-if="node.type === 2" class="workflow-item">
    <div class="workflow-icon">
      <span>抄</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '抄送人' }}</div>
      <div class="workflow-desc">
        {{ formatAssignees(node.nodeAssigneeList) }}
        <div v-if="node.allowSelection">允许发起人自选抄送人</div>
      </div>
    </div>
    <!-- 编辑模式下的添加按钮 -->
    <div v-if="mode === 'edit' && node.allowSelection" 
       class="edit-add-btn"
       @click="handleAddCandidate">
      <div class="add-icon">+</div>
    </div>
  </div>

  <!-- 条件分支节点 -->
  <div v-else-if="node.type === 4" class="workflow-item condition-branch">
    <div class="workflow-icon">
      <span>条</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">条件分支</div>
      <div class="condition-groups">
        <div v-for="(cn, index) in node.conditionNodes" :key="index" class="condition-group">
          <div class="condition-title">{{ cn.nodeName || '条件' + (index + 1) }}</div>
          <div class="condition-expressions">
            <div v-for="(group, groupIndex) in cn.conditionList" :key="groupIndex" class="expression-group">
              <div class="group-operator" v-if="groupIndex > 0">或</div>
              <div class="expression-items">
                <div v-for="(expr, exprIndex) in group" :key="exprIndex" class="expression-item">
                  <div class="item-operator" v-if="exprIndex > 0">且</div>
                  <div class="item-content">
                    {{ formatExpression(expr) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <node-renderer :node="cn.childNode" :mode="mode"/>
        </div>
      </div>
    </div>
  </div>

  <!-- 办理子流程 -->
  <div v-else-if="node.type === 5" class="workflow-item">
    <div class="workflow-icon">
      <span>子</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '子流程' }}</div>
      <div class="workflow-desc">
        <div v-if="node.callProcess">
          调用流程: {{ getProcessName(node.callProcess) }}
        </div>
        <div v-if="node.actionUrl">
          表单URL: {{ node.actionUrl }}
        </div>
      </div>
    </div>
  </div>

  <!-- 定时器任务 -->
  <div v-else-if="node.type === 6" class="workflow-item">
    <div class="workflow-icon">
      <span>时</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '定时器' }}</div>
      <div class="workflow-desc" v-if="node.extendConfig?.time">
        触发时间: {{ node.extendConfig.time }}
      </div>
    </div>
  </div>

  <!-- 触发器任务 -->
  <div v-else-if="node.type === 7" class="workflow-item">
    <div class="workflow-icon">
      <span>触</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '触发器' }}</div>
      <div class="workflow-desc">
        <div>
          {{ node.triggerType === '1' ? '立即执行' : '延迟执行' }}
        </div>
        <div v-if="node.triggerType === '2' && node.delayType">
          {{ node.delayType === '1' ? '固定时长' : '自动计算' }}:
          {{ node.extendConfig?.time || '' }}
        </div>
      </div>
    </div>
  </div>

  <!-- 并行分支 -->
  <div v-else-if="node.type === 8" class="workflow-item parallel-branch">
    <div class="workflow-icon">
      <span>并</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">并行分支</div>
      <div class="parallel-groups">
        <div v-for="(pn, index) in node.parallelNodes" :key="index" class="parallel-group">
          <node-renderer :node="pn" :mode="mode"/>
        </div>
      </div>
    </div>
  </div>

  <!-- 包容分支 -->
  <div v-else-if="node.type === 9" class="workflow-item inclusive-branch">
    <div class="workflow-icon">
      <span>包</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">包容分支</div>
      <div class="inclusive-groups">
        <div v-for="(in_node, index) in node.inclusiveNodes" :key="index" class="inclusive-group">
          <div class="inclusive-title">{{ in_node.nodeName || '条件' + (index + 1) }}</div>
          <div class="inclusive-expressions">
            <div v-for="(group, groupIndex) in in_node.conditionList" :key="groupIndex" class="expression-group">
              <div class="group-operator" v-if="groupIndex > 0">或</div>
              <div class="expression-items">
                <div v-for="(expr, exprIndex) in group" :key="exprIndex" class="expression-item">
                  <div class="item-operator" v-if="exprIndex > 0">且</div>
                  <div class="item-content">
                    {{ formatExpression(expr) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <node-renderer :node="in_node.childNode" :mode="mode"/>
        </div>
      </div>
    </div>
  </div>

  <!-- 路由分支 -->
  <div v-else-if="node.type === 23" class="workflow-item route-branch">
    <div class="workflow-icon">
      <span>路</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">路由分支</div>
      <div class="route-groups">
        <div v-for="(rn, index) in node.routeNodes" :key="index" class="route-group">
          <div class="route-title">{{ rn.nodeName || '路由' + (index + 1) }}</div>
          <div class="route-info" v-if="rn.nodeKey">
            目标节点: {{ getRouteTarget(rn.nodeKey) }}
          </div>
          <div class="route-expressions">
            <div v-for="(group, groupIndex) in rn.conditionList" :key="groupIndex" class="expression-group">
              <div class="group-operator" v-if="groupIndex > 0">或</div>
              <div class="expression-items">
                <div v-for="(expr, exprIndex) in group" :key="exprIndex" class="expression-item">
                  <div class="item-operator" v-if="exprIndex > 0">且</div>
                  <div class="item-content">
                    {{ formatExpression(expr) }}
                  </div>
                </div>
              </div>
            </div>
          </div>
          <node-renderer :node="rn.childNode" :mode="mode"/>
        </div>
      </div>
    </div>
  </div>

  <!-- 结束节点 -->
  <div v-else-if="node.type === -1" class="workflow-item">
    <div class="workflow-icon">
      <span>结</span>
    </div>
    <div class="workflow-content">
      <div class="workflow-title">结束</div>
    </div>
  </div>

  <!-- 未知节点类型 -->
  <div v-else class="workflow-item">
    <div class="workflow-icon">
      <span>?</span>
    </div>
    <div class="workflow-line"></div>
    <div class="workflow-content">
      <div class="workflow-title">{{ node.nodeName || '未知节点类型' }}</div>
      <div class="workflow-desc">类型: {{ node.type }}</div>
    </div>
  </div>

  <!-- 子节点 (对于非分支类型的节点) -->
  <node-renderer v-if="node.childNode && ![4, 8, 9, 23].includes(node.type)" :node="node.childNode" :mode="mode" />

  <!-- 处理分支节点的子节点 -->
  <node-renderer v-if="node.childNode && [4, 8, 9, 23].includes(node.type)" :node="node.childNode" :mode="mode" />
  <!-- 添加用户/角色选择模态框 -->
  <user-role-selector
    v-model="selectorVisible"
    ref="userRoleSelector"
    @closed="handleSelectorClosed"
  />
</div>
</template>

<script setup>
import { defineProps, inject, provide, ref, watchEffect } from 'vue';
import UserRoleSelector from './scWorkflow/select.vue';

const props = defineProps({
  node: {
    type: Object,
    required: true,
    default: () => ({
      type: -1,
      nodeName: '未知节点',
      childNode: null
    })
  },
  mode: {
    type: String,
    required: false,
    default: 'preview',
    validator: (value) => ['preview', 'edit'].includes(value)
  }
});

// 创建一个当前用户对象的变量
const currentUserInfo = ref({
  id: '20240815',
  name: '田重辉'
})

watchEffect(() => {
  console.log('node', props.node);
  // 如果节点已有审批人列表，则不需要处理
  if (props.node?.nodeAssigneeList?.length > 0) return;
  
  // 确保nodeAssigneeList存在
  if (!props.node.nodeAssigneeList) {
    props.node.nodeAssigneeList = [];
  }
  
  // 根据节点类型处理审批人
  if (props.node.type === 0) {
    // 发起人节点
    props.node.nodeAssigneeList.push(currentUserInfo.value);
  } else if (props.node.type === 1 && props.node.setType === 5) {
    props.node.nodeAssigneeList.push(currentUserInfo.value);
  }
});


// 用于控制选择器模态框的显示
const selectorVisible = ref(false);
const userRoleSelector = ref(null);
const currentEditingNode = ref(null);

// 尝试从父组件注入更新函数
const updateNodeConfig = inject('updateNodeConfig', null);

// 为子组件提供更新函数
provide('updateNodeConfig', updateNodeConfig);

// 获取状态指示器的类名
const getStatusIndicatorClass = (node) => {
  
  const statusMap = {
    0: 'status-active',       // 活动
    1: 'status-skipped',      // 跳转
    2: 'status-completed',    // 完成
    3: 'status-rejected',     // 拒绝
    4: 'status-canceled',     // 撤销审批
    5: 'status-timeout',      // 超时
    6: 'status-terminated',   // 终止
    7: 'status-rejected-terminated', // 驳回终止
    8: 'status-auto-completed', // 自动完成
    9: 'status-auto-rejected',  // 自动驳回
    10: 'status-auto-skipped',  // 自动跳转
    11: 'status-rejected-skipped', // 驳回跳转
    12: 'status-rejected-reapproved-skipped', // 驳回重新审批跳转
    13: 'status-route-skipped' // 路由跳转
  };
  
  return statusMap[node.taskState] || '';
};

// 获取节点状态文本-发起节点
const getStartNodeStateText = (node) => {
  const stateTexts = {
    0: '待发起',
    1: '跳转',
    2: '已发起',
    3: '已拒绝',
    4: '已撤销',
    5: '已超时',
    6: '已终止',
    7: '驳回终止',
    8: '自动完成',
    9: '自动驳回',
    10: '自动跳转',
    11: '驳回跳转',
    12: '驳回重审跳转',
    13: '路由跳转'
  };
  
  return stateTexts[node.taskState] || '';
};

// 获取节点状态文本
const getNodeStateText = (node) => {
  const stateTexts = {
    0: '审批中', 
    1: '跳转',
    2: '已通过',
    3: '已拒绝',
    4: '已撤销',
    5: '已超时',
    6: '已终止',
    7: '驳回终止',
    8: '自动完成',
    9: '自动驳回',
    10: '自动跳转',
    11: '驳回跳转',
    12: '驳回重审跳转',
    13: '路由跳转'
  };
  
  return stateTexts[node.taskState] || '';
};

// 格式化时间
const formatTime = (time) => {
  if (!time) return '';
  
  const date = new Date(time);
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  const hours = date.getHours().toString().padStart(2, '0');
  const minutes = date.getMinutes().toString().padStart(2, '0');
  
  return `${year}-${month}-${day} ${hours}:${minutes}`;
};

// 格式化处理耗时
const formatDuration = (duration) => {
  if (!duration) return '';
  
  // 如果是数字，假设是毫秒
  if (typeof duration === 'number') {
    const seconds = Math.floor(duration / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
      return `${hours}小时${minutes % 60}分钟`;
    } else if (minutes > 0) {
      return `${minutes}分钟${seconds % 60}秒`;
    } else {
      return `${seconds}秒`;
    }
  }
  
  // 如果已经是字符串格式
  return duration;
};

// 修改处理函数，打开选择器
const handleAddCandidate = () => {
  console.log('打开添加候选人弹窗', props.node);
  currentEditingNode.value = props.node;
  
  // 打开选择器，传递类型和现有选择
  if (userRoleSelector.value) {
    // 根据节点类型决定打开的选择器类型 (1为人员，2为角色)
    // const selectorType = props.node.setType === 3 ? 2 : 1;
    userRoleSelector.value.open(1, props.node.nodeAssigneeList || [], props.node?.selectMode);
  }
};

// 处理选择器关闭后的回调
const handleSelectorClosed = () => {
  // 如果关闭时没有选择，则不进行任何操作
  if (!userRoleSelector.value || !currentEditingNode.value) return;
  
  // 获取选择的结果
  const selectedItems = userRoleSelector.value.value;
  
  // 更新流程数据
  if (updateNodeConfig && selectedItems.length > 0) {
    // 创建一个更新函数，描述如何更新当前节点
    const updateFn = (rootNode) => {
      // 辅助函数用于递归查找和更新节点
      const findAndUpdateNode = (node) => {
        if (!node) return node;
        
        // 如果找到了当前正在编辑的节点
        if (node === currentEditingNode.value) {
          // 更新当前节点
          return {
            ...node,
            nodeAssigneeList: selectedItems
          };
        }
        
        // 递归检查childNode
        if (node.childNode) {
          const updatedChildNode = findAndUpdateNode(node.childNode);
          if (updatedChildNode !== node.childNode) {
            return { ...node, childNode: updatedChildNode };
          }
        }
        
        // 处理条件分支节点
        if (node.conditionNodes) {
          const newConditionNodes = [...node.conditionNodes];
          let updated = false;
          
          for (let i = 0; i < newConditionNodes.length; i++) {
            const updatedNode = findAndUpdateNode(newConditionNodes[i]);
            if (updatedNode !== newConditionNodes[i]) {
              newConditionNodes[i] = updatedNode;
              updated = true;
            }
            
            // 还需要检查每个条件节点的childNode
            if (newConditionNodes[i].childNode) {
              const updatedChildNode = findAndUpdateNode(newConditionNodes[i].childNode);
              if (updatedChildNode !== newConditionNodes[i].childNode) {
                newConditionNodes[i] = { ...newConditionNodes[i], childNode: updatedChildNode };
                updated = true;
              }
            }
          }
          
          if (updated) {
            return { ...node, conditionNodes: newConditionNodes };
          }
        }
        
        // 处理其他类型的分支节点
        // ... (为其他节点类型添加类似的处理逻辑)
        
        return node;
      };
      
      // 从根节点开始查找
      return findAndUpdateNode(rootNode);
    };
    
    // 调用父组件提供的更新函数
    updateNodeConfig(updateFn, []);
  }
  
  // 重置当前编辑节点
  currentEditingNode.value = null;
};

// 保留所有原有的逻辑函数
const formatAssignees = (assigneeList) => {
  if (!assigneeList || assigneeList.length === 0) return '';

  return assigneeList.map(assignee => {

    let displayText = assignee.name || '';
    if (assignee.weight) {
      displayText += ` (${assignee.weight}%)`;
    }
    return displayText;
  }).join('、');
};

const getApproveTypeText = (setType) => {
  const types = {
    1: '指定成员',
    2: '主管',
    3: '角色',
    4: '发起人自选',
    5: '发起人自己',
    6: '连续多级主管',
    7: '部门',
    8: '指定候选人'
  };
  return types[setType] || '未知类型';
};

const getCandidateTypeText = (type) => {
  const types = {
    0: '用户',
    1: '角色',
    2: '部门'
  };
  return types[type] || '未知类型';
};

const getExamineModeText = (examineMode) => {
  const modes = {
    0: '发起',
    1: '依次审批',
    2: '会签',
    3: '或签',
    4: '票签',
    9: '抄送'
  };
  return modes[examineMode] || '';
};

const getLevelText = (node) => {
  if (node.setType === 2) {
    return `第${node.examineLevel || 1}级主管`;
  } else if (node.setType === 6) {
    if (node.directorMode === 0) {
      return '直到最上级主管';
    } else {
      return `连续${node.directorLevel || 1}级主管`;
    }
  }
  return '';
};

const showAssignees = (node) => {
  return node.nodeAssigneeList?.length > 0;
};

const getProcessName = (callProcess) => {
  if (!callProcess) return '';
  if (callProcess.includes(':')) {
    return callProcess.split(':')[1];
  }
  return callProcess;
};

const formatExpression = (expr) => {
  if (!expr) return '';

  let result = '';
  if (expr.label) {
    result += expr.label;
  } else if (expr.field) {
    result += expr.field;
  }

  if (expr.operator) {
    result += ' ' + getOperatorText(expr.operator) + ' ';
  }

  if (expr.value !== undefined && expr.value !== null) {
    result += expr.value;
  }

  return result;
};

const getOperatorText = (operator) => {
  const operators = {
    '==': '等于',
    '!=': '不等于',
    '>': '大于',
    '>=': '大于等于',
    '<': '小于',
    '<=': '小于等于',
    'include': '包含',
    'notinclude': '不包含'
  };
  return operators[operator] || operator;
};

const getRouteTarget = (nodeKey) => {
  if (!nodeKey) return '';
  if (nodeKey.startsWith('route:')) {
    return nodeKey.split(':')[1];
  }
  return nodeKey;
};
</script>

<style scoped>
.workflow-container {
  width: 100%;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

.workflow-item {
  position: relative;
  display: flex;
  margin-bottom: 8px;
  padding-left: 20px;
}

.workflow-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #2b7bdb;
  color: white;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-right: 15px;
  z-index: 1;
  flex-shrink: 0;
  position: relative;
}

/* 状态指示器样式 */
.status-indicator {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background-color: #fff;
  border: 1px solid #fff;
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
}

/* 审批状态指示器样式 */
.status-active {
  background-color: #409eff;
}

.status-active::before,
.status-active::after {
  content: '';
  position: absolute;
  background-color: #fff;
  border-radius: 50%;
  width: 2px;
  height: 2px;
  animation: loading 1.4s infinite ease-in-out both;
}

.status-active::before {
  bottom: 5px;
  left: 3px;
  animation-delay: -0.32s;
}

.status-active::after {
  bottom: 5px;
  right: 3px;
  animation-delay: 0.32s;
}

@keyframes loading {
  0%, 80%, 100% { opacity: 0; }
  40% { opacity: 1; }
}

/* 完成状态 */
.status-completed,
.status-auto-completed {
  background-color: #67c23a;
}

.status-completed::before,
.status-auto-completed::before {
  content: '✓';
  position: absolute;
  color: #fff;
  font-size: 10px;
  line-height: 10px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

/* 拒绝状态 */
.status-rejected,
.status-auto-rejected {
  background-color: #f56c6c;
}

.status-rejected::before,
.status-auto-rejected::before {
  content: '✕';
  position: absolute;
  color: #fff;
  font-size: 10px;
  line-height: 10px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

/* 跳过状态 */
.status-skipped,
.status-auto-skipped,
.status-rejected-skipped,
.status-rejected-reapproved-skipped,
.status-route-skipped {
  background-color: #909399;
}

.status-skipped::before,
.status-auto-skipped::before,
.status-rejected-skipped::before,
.status-rejected-reapproved-skipped::before,
.status-route-skipped::before {
  content: '→';
  position: absolute;
  color: #fff;
  font-size: 10px;
  line-height: 10px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

/* 其他状态 */
.status-canceled,
.status-terminated,
.status-rejected-terminated {
  background-color: #ff9800;
}

.status-timeout {
  background-color: #e6a23c;
}

.status-timeout::before {
  content: '!';
  position: absolute;
  color: #fff;
  font-size: 10px;
  line-height: 10px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-weight: bold;
}

.workflow-line {
  position: absolute;
  left: 40px;
  top: 40px;
  bottom: 0;
  width: 1px;
  background-color: #eee;
}

.workflow-item:last-child .workflow-line {
  display: none;
}

.workflow-content {
  flex: 1;
  padding-bottom: 20px;
  border-bottom: 1px solid #eee;
}

.workflow-item:last-child .workflow-content {
  border-bottom: none;
}

.workflow-admin {
  border-bottom: 1px solid #eee;
}

.workflow-item:last-child .workflow-admin {
  border-bottom: none;
}

.state-tag {
  margin-left: 8px;
  padding: 2px 8px;
  font-size: 12px;
  border-radius: 10px;
  font-weight: normal;
  background-color: #f0f0f0;
  color: #606266;
}

/* 编辑模式按钮样式 */
.edit-add-btn {
  display: flex;
  align-items: center;
  padding-bottom: 20px;
}

.add-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  background-color: #2b7bdb;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  transition: all 0.3s;
}

.add-icon:hover {
  background-color: #1a5aad;
  transform: scale(1.1);
}

.workflow-title {
 font-size: 14px;
 font-weight: 500;
 margin-bottom: 5px;
 display: flex;
 align-items: center;
}

.workflow-desc {
 font-size: 12px;
 color: #666;
 line-height: 1.5;
}

.workflow-desc>div {
 margin-bottom: 4px;
}

/* 任务历史记录样式 */
.task-history {
  margin-top: 15px;
  padding-top: 10px;
  border-top: 1px dashed #eaeaea;
}

.task-history-item {
  display: flex;
  margin-bottom: 12px;
  padding-left: 10px;
}

.task-history-avatar {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background-color: #909399;
  color: white;
  display: flex;
  justify-content: center;
  align-items: center;
  margin-right: 10px;
  flex-shrink: 0;
  position: relative;
  font-size: 12px;
}

.task-history-avatar .status-indicator {
  width: 12px;
  height: 12px;
  right: -2px;
  bottom: -2px;
}

.task-history-content {
  flex: 1;
  font-size: 12px;
}

.task-history-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 5px;
}

.task-history-user {
  font-weight: 500;
  color: #333;
}

.task-history-time {
  color: #999;
}

.task-history-duration {
  color: #666;
  margin-bottom: 3px;
}

.task-history-comment {
  background-color: #f5f7fa;
  padding: 5px 8px;
  border-radius: 4px;
  margin-top: 5px;
  color: #606266;
  white-space: pre-wrap;
}

.task-history-expire {
  color: #e6a23c;
  margin-top: 3px;
  font-size: 11px;
}

.task-history-transfer {
  color: #409eff;
  margin-top: 3px;
  font-style: italic;
}

/* 悬停显示更多信息 */
.task-history-item:hover {
  background-color: #f9f9f9;
  border-radius: 4px;
}

/* 任务退回/驳回等特殊状态的样式 */
.task-history-item.task-rejected .task-history-avatar {
  background-color: #f56c6c;
}

.task-history-item.task-returned .task-history-avatar {
  background-color: #e6a23c;
}

/* 分支节点样式 */
.condition-branch,
.parallel-branch,
.inclusive-branch,
.route-branch {
 margin-bottom: 20px;
}

.condition-groups,
.parallel-groups,
.inclusive-groups,
.route-groups {
 margin-top: 10px;
 border-left: 2px dashed #ddd;
 padding-left: 15px;
}

.condition-group,
.parallel-group,
.inclusive-group,
.route-group {
 margin-bottom: 15px;
 padding: 10px;
 background-color: #f9f9f9;
 border-radius: 4px;
}

.condition-title,
.inclusive-title,
.route-title {
 font-weight: 500;
 font-size: 13px;
 margin-bottom: 8px;
 color: #333;
}

.condition-expressions,
.inclusive-expressions,
.route-expressions {
 font-size: 12px;
 color: #666;
 margin-bottom: 10px;
}

.expression-group {
 margin-bottom: 8px;
}

.group-operator {
 color: #f56c6c;
 font-weight: 500;
 margin: 4px 0;
 font-size: 12px;
}

.expression-items {
 margin-left: 10px;
}

.item-operator {
 color: #67c23a;
 font-weight: 500;
 margin: 4px 0;
 font-size: 12px;
}

.item-content {
 margin-left: 5px;
}

/* 根据节点类型设置不同颜色 */
.workflow-item:nth-child(1) .workflow-icon {
 background-color: #2b7bdb; /* 发起人 */
}

.workflow-item:nth-child(2) .workflow-icon {
 background-color: #e6a23c; /* 审批人 */
}

.workflow-item:nth-child(3) .workflow-icon {
 background-color: #909399; /* 抄送人 */
}

.workflow-item:nth-child(4) .workflow-icon {
 background-color: #f56c6c; /* 条件分支 */
}

.workflow-item:nth-child(5) .workflow-icon {
 background-color: #67c23a; /* 子流程 */
}

.workflow-item:nth-child(6) .workflow-icon {
 background-color: #8e44ad; /* 定时器 */
}

.workflow-item:nth-child(7) .workflow-icon {
 background-color: #16a085; /* 触发器 */
}

.workflow-item:nth-child(8) .workflow-icon {
 background-color: #d35400; /* 并行分支 */
}

.workflow-item:nth-child(9) .workflow-icon {
 background-color: #c0392b; /* 包容分支 */
}

.workflow-item:nth-child(10) .workflow-icon {
 background-color: #7f8c8d; /* 路由分支 */
}

.workflow-item:nth-child(11) .workflow-icon {
 background-color: #34495e; /* 结束节点 */
}

/* 响应式调整 */
@media (max-width: 480px) {
 .workflow-item {
   padding-left: 15px;
 }

 .workflow-icon {
   width: 32px;
   height: 32px;
   margin-right: 10px;
 }

 .status-indicator {
   width: 10px;
   height: 10px;
 }

 .workflow-line {
   left: 31px;
 }

 .workflow-content {
   padding-bottom: 15px;
 }
 
 .edit-add-btn {
   right: -20px;
   bottom: 10px;
 }
 
 .add-icon {
   width: 20px;
   height: 20px;
   font-size: 16px;
 }
 
 .state-tag {
   font-size: 10px;
   padding: 1px 6px;
 }

 .task-history-item {
    padding-left: 5px;
  }
  
  .task-history-avatar {
    width: 24px;
    height: 24px;
    margin-right: 8px;
  }
  
  .task-history-content {
    font-size: 11px;
  }
}
</style>