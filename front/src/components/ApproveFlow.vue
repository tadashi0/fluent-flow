<template>
  <div class="modal">
    <div class="modal-body">

      <div class="process-info">
        流程审批状态（流程{{getProcessStateText()}}）
      </div>

      <div class="workflow">
        <node-renderer :mode="mode" :node="flowData.nodeConfig" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, ref, computed, watchEffect, watch, reactive } from 'vue';
import { getInstanceModel, getInstanceInfo, getTaskList, getBackList } from '@/api/process'
import NodeRenderer from './NodeRenderer.vue';

const props = defineProps({
  businessKey: String,
  mode: {
    type: String,
    default: 'preview'
  }
});

const flowData = ref({})
const state = ref(-1)



// 初始化调用接口获取流程数据
watchEffect(async () => {
  try {
    // 并发请求所有接口
    const [instanceInfoResult, modelResult, taskResult] = await Promise.all([
      getInstanceInfo(props.businessKey),
      getInstanceModel(props.businessKey),
      getTaskList(props.businessKey),
    ])

    // 处理数据逻辑
    const {instanceId, instanceState } = instanceInfoResult.data
    const backListResult = await getBackList(instanceId)
    console.log('backListResult: ', backListResult)
    state.value = instanceState
    const processModel = JSON.parse(modelResult.data)
    traverseNode(processModel.nodeConfig, taskResult.data)
    flowData.value = processModel
  } catch (error) {
    console.error('数据加载失败:', error)
  }
});

const traverseNode = (node, taskList) => {
  if (node?.childNode) {
    traverseNode(node.childNode, taskList)
  }
  if (node?.nodeKey && [0, 1, 3].includes(node.type)) {
    const list = taskList.filter(t => t.taskKey === node.nodeKey)
    console.log('当前节点: ', node.nodeName, ', 流程中转轨迹', list)
    const task = list[list.length - 1]
    if (task) {
      node.taskState = task.taskState
      node.taskList = list
    }
  }
}

// 获取流程状态
const getProcessStateText = () => {
  const stateTexts = {
    0: '暂存待审',
    1: '审批中',
    2: '审批通过',
    3: '审批拒绝【 驳回结束流程 】',
    4: '撤销审批',
    5: '超时结束',
    6: '强制终止',
    7: '自动通过',
    8: '自动拒绝'
  };

  return stateTexts[state.value + 1] || '';
};

</script>

<style scoped>
.modal-body {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.process-info {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}

.workflow {
  margin-top: 20px;
}
</style>
