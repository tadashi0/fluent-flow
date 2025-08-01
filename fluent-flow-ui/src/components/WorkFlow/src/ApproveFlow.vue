<template>
  <div class="process-approval">
    <div class="process-info">
      流程审批状态（流程{{getProcessStateText()}}）
    </div>
    <node-renderer :node="modelContent.nodeConfig" />
    
    <!-- 审批操作按钮组 -->
    <div class="modal-footer" v-if="mode === 'edit'">
      <el-button @click="handleCancel">取消</el-button>
      <el-dropdown popper-class="custom-dropdown-menu" placement="top">
        <el-button>更多</el-button>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item>
              <el-button class="custom-btn" type="info" @click="openActionDialog('transfer')">转交</el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button class="custom-btn" type="warning" @click="openActionDialog('reclaim')">回退</el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button class="custom-btn" type="success" @click="openActionDialog('countersign')">加签</el-button>
            </el-dropdown-item>
            <el-dropdown-item>
              <el-button class="custom-btn" type="danger" @click="openActionDialog('terminate')">终止</el-button>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
      <el-button class="custom-btn" type="danger" @click="openActionDialog('reject')">驳回</el-button>
      <el-button type="primary" @click="openActionDialog('approve')">同意</el-button>
    </div>
  </div>
      <!-- 引用审批操作弹窗组件 -->
      <process-action-dialog
      v-model:visible="actionDialogVisible"
      :business-key="businessKey"
      :action-type="currentActionType"
      :reclaim-nodes="reclaimNodes"
      @cancel="handleActionCancel"
      @confirm="handleActionConfirm"
    />
</template>

<script setup>
import { ref, computed, watchEffect } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
import { getInstanceModel, getInstanceInfo, getTaskList, getSubInstanceId, getBackList, approveProcess, rejectProcess, reclaimProcess, terminateProcess, transferProcess, countersignProcess } from '@/api/workflow';
import NodeRenderer from './NodeRenderer.vue';
import ProcessActionDialog from './ProcessActionDialog.vue';

const props = defineProps({
  businessKey: {
    type: String,
    required: true
  },
  mode: {
    type: String,
    default: 'edit'
  },
  onApprove: Function,
});

const emit = defineEmits(['cancel', 'refresh']);

const modelContent = ref({});
const state = ref(-1);
const reclaimNodes = ref([]);

// 操作弹窗相关
const actionDialogVisible = ref(false);
const currentActionType = ref('');

// 打开操作弹窗
const openActionDialog = async (actionType) => {
  currentActionType.value = actionType;
  
  // 如果是回退操作，需要先获取可回退节点列表
  if (actionType === 'reclaim') {
    try {
      // 获取实例信息
      const instanceRes = await getInstanceInfo(props.businessKey);
      const instanceId = instanceRes.instanceId;
      
      // 获取可回退节点列表
      const backRes = await getBackList(instanceId);
      if (backRes && backRes?.length) {
        reclaimNodes.value = backRes;
        actionDialogVisible.value = true;
      } else {
        ElMessage.warning('没有可回退的节点');
      }
    } catch (error) {
      console.error('获取回退节点失败:', error);
      ElMessage.error('获取回退节点失败');
    }
  } else {
    // 其他操作直接打开弹窗
    actionDialogVisible.value = true;
  }
};

// 取消操作
const handleActionCancel = () => {
  actionDialogVisible.value = false;
};

// 确认操作
const handleActionConfirm = async (data) => {
  try {
    console.log('操作数据:', data);
    
    switch (data.actionType) {
      case 'approve':
        await handleApprove(data);
        ElMessage.success('审批成功');
        break;
      case 'reject':
        await handleReject(data);
        ElMessage.success('驳回成功');
        break;
      case 'transfer':
        await handleTransfer(data);
        ElMessage.success(`已转交给 ${data.transferUser?.name} 进行审批`);
        break;
      case 'reclaim':
        await handleReclaim(data);
        ElMessage.success(`已回退到 ${data.reclaimNode?.taskName} 节点`);
        break;
      case 'terminate':
        await handleTerminate(data);
        ElMessage.success('终止成功');
        break;
      case 'countersign':
        await handleCountersign(data);
        ElMessage.success('加签成功');
        break;
    }
    // 刷新流程数据
    handleCancel();
    emit('refresh');
  } catch (error) {
    console.error('操作失败:', error);
  }
};

// 同意操作
const handleApprove = async (data) => {
  try {
    await props.onApprove()
    await approveProcess(data.businessKey,{
        comment: data.comment,
        ccUsers: data.ccUsers
    });
  } catch (error) {
    console.error('审批操作失败:', error);
    throw error;
  }
};

// 驳回操作
const handleReject = async (data) => {
  try {
    await rejectProcess(data.businessKey, {
      comment: data.comment,
      ccUsers: data.ccUsers
    });
  } catch (error) {
    console.error('驳回操作失败:', error);
    throw error;
  }
};

// 转交操作
const handleTransfer = async (data) => {
  try {
    const { id, name} = data.transferUser
    await transferProcess(data.businessKey, {
      comment: data.comment,
      ccUsers: data.ccUsers,
      transferUsers: {createId: id, createBy: name}
    });
  } catch (error) {
    console.error('转交操作失败:', error);
    throw error;
  }
};

// 回退操作
const handleReclaim = async (data) => {
  try {
    await reclaimProcess(data.businessKey, {
      comment: data.comment,
      ccUsers: data.ccUsers,
      reclaimNodeKey: data.reclaimNode?.taskKey,
      reclaimNodeName: data.reclaimNode?.taskName,
    });
  } catch (error) {
    console.error('回退操作失败:', error);
    throw error;
  }
};

// 终止操作
const handleTerminate = async (data) => {
  try {
    await terminateProcess(data.businessKey, {
      comment: data.comment,
      ccUsers: data.ccUsers
    });
  } catch (error) {
    console.error('终止操作失败:', error);
    throw error;
  }
};

// 加签操作
const handleCountersign = async (data) => {
  try {
    await countersignProcess(data.businessKey, {
      comment: data.comment,
      ccUsers: data.ccUsers,
      signType: data.signType, // 前加签(true)或后加签(false)
      counterSignUsers: data.counterSignUsers, // 加签人员
      nodeName: data.nodeName // 节点名称
    });
  } catch (error) {
    console.error('加签操作失败:', error);
    throw error;
  }
};

const handleCancel = () => {
  emit('cancel');
};

// 获取流程状态文本
const getProcessStateText = () => {
    const stateTexts = {
    '-2': '已暂停',
    '-1': '待发起',
    0: '审批中',
    1: '审批通过',
    2: '审批拒绝【 驳回结束流程 】',
    3: '撤销审批',
    4: '超时结束',
    5: '强制终止',
    6: '自动通过',
    7: '自动拒绝'
  };
  
  return stateTexts[state.value] || '';
};

// 初始化调用接口获取流程数据
watchEffect(async () => {
  if (props.businessKey) {
    try {
      // 并发请求所有接口
      const [instanceInfoResult, modelResult, taskResult] = await Promise.all([
        getInstanceInfo(props.businessKey),
        getInstanceModel(props.businessKey),
        getTaskList(props.businessKey),
      ]);
      
      // 处理数据逻辑
      const { taskState, currentNodeKey } = instanceInfoResult;
      state.value = taskState;
      const processModel = JSON.parse(modelResult.modelContent);
      // await traverseAutoNode(processModel.nodeConfig, taskState, currentNodeKey);
      await traverseNode(processModel.nodeConfig, taskResult);
      modelContent.value = processModel;
    } catch (error) {
      console.error('数据加载失败:', error);
    }
  }
});

const traverseAutoNode = async (node, taskState, currentNodeKey) => { 
  
  if (node?.childNode) {
    await traverseAutoNode(node.childNode, taskState, currentNodeKey);
  }
  if (node?.type === 4) {
    // 这是一个条件分支节点
    node.conditionNodes.forEach(async (conditionNode) => {
      await traverseAutoNode(conditionNode.childNode, taskState, currentNodeKey);
    });
  }
  if (node?.nodeKey === currentNodeKey) {
    node.taskState = taskState + 2;
  }
}

const traverseNode = async (node, taskList) => {
  console.log('遍历节点:', node);
  if (node?.childNode) {
    await traverseNode(node.childNode, taskList);
  }
  if (node?.type === 4) {
    // 这是一个条件分支节点
    node.conditionNodes.forEach(async (conditionNode) => {
      await traverseNode(conditionNode.childNode, taskList);
    });
  }
  if (node?.type === 5) {
    // 这是一个子流程节点
    const instanceId = await getSubInstanceId(parseCallProcess(node.callProcess).id, props.businessKey);
    if(instanceId) {
      const [instanceInfoResult, modelResult, taskResult] = await Promise.all([
          getInstanceInfo(instanceId),
          getInstanceModel(instanceId),
          getTaskList(instanceId),
      ]);
        // 处理数据逻辑
        const { taskState } = instanceInfoResult;
        node.state = taskState;
        const processModel = JSON.parse(modelResult.modelContent);
        await traverseNode(processModel.nodeConfig, taskResult);
        node.nodeConfig = processModel.nodeConfig;
    }
  }
  // if (node?.nodeKey && [0, 1, 3].includes(node.type)) {
  if (node?.nodeKey) {
    const list = taskList.filter(t => t.taskKey === node.nodeKey);
    const task = list[list.length - 1];
    if (task) {
      node.taskState = task.taskState;
      node.taskList = list;

      console.log('节点信息:', node);
      console.log('任务信息:', list);
    }
  }
};

// 解析callProcess值
const parseCallProcess = (callProcess) => {
  if (!callProcess) return null;
  const parts = callProcess.split(':');
  return {
    id: parts[0],
    name: parts[1] || '未命名子流程'
  };
};
</script>

<style scoped>
.process-approval {
  max-width: 700px;
  padding: 20px;
  padding-bottom: 0px;
}

.process-info {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  flex-wrap: wrap;
  gap: 8px;

  .el-button.custom-btn:not(.el-button--primary):not(.is-link) {
    color: var(--el-button-text-color);
    background-color: var(--el-button-bg-color);

    &:hover {
      background-color: var(--el-button-hover-border-color);
      color: var(--el-button-hover-text-color);
    }
  }
}

.custom-dropdown-menu .el-button.custom-btn:not(.el-button--primary):not(.is-link) {
  color: var(--el-button-text-color);
  background-color: var(--el-button-bg-color);
}

.custom-dropdown-menu .el-button.custom-btn:not(.el-button--primary):not(.is-link):hover {
  background-color: var(--el-button-hover-border-color);
  color: var(--el-button-hover-text-color);
}

</style>