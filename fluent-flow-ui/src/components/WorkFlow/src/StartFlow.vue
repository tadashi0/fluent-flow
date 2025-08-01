<template>
  <div class="workflow" v-loading="loading">
    <node-renderer :mode="mode" :node="modelContent.nodeConfig" />
  </div>
  <div class="modal-footer" v-if="mode === 'edit'">
    <el-button @click="handleCancel">取消</el-button>
    <el-button type="primary" @click="handleSave">保存</el-button>
    <el-button type="primary" @click="handleSubmit">提交</el-button>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, inject, provide, computed, watchEffect, watch, ref } from 'vue';
import { ElMessage } from 'element-plus'
import { getProcessInfo, getInstanceModel, saveProcess, startProcess } from '@/api/workflow'
import NodeRenderer from './NodeRenderer.vue';

const props = defineProps({
  processKey: String,
  businessKey: String,
  mode: {
    type: String,
    default: 'edit'
  },
  // 新增父组件操作函数
  onSubmit: Function,
  onSave: Function
});

const emit = defineEmits(['cancel', 'refresh'])

const modelContent = ref({})

const handleCancel = () => {
  emit('cancel')
}

const loading = ref(false)

const handleSave = async () => {
  try {
    loading.value = true
    // 1. 先调用父组件保存逻辑
    const params = await props.onSave()
    // 2. 执行子组件保存逻辑
    const data = {
      processKey: props.processKey,
      modelContent: JSON.stringify(modelContent.value)
    }
    // await request?.post('/task/save/' + businessKey, data)
    await saveProcess(params.id, data)
    handleCancel()
    emit('refresh');
    ElMessage.success('保存成功')
  } catch (error) {
    console.error('保存失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSubmit = async () => {
  try {
    loading.value = true
    // 1. 先调用父组件提交逻辑
    const params = await props.onSubmit()
    
    // 2. 执行子组件提交逻辑
    const data = {
      processKey: props.processKey,
      modelContent: JSON.stringify(modelContent.value),
    }
    const firstNode = modelContent.value?.nodeConfig?.childNode
    if ([4, 8, 9].includes(firstNode?.type)) {
      const variable = collectFields(firstNode.conditionNodes)
      for (const key in variable) {
        if (variable.hasOwnProperty(key) && params.hasOwnProperty(key)) {
          variable[key] = params[key];
        }
      } 
      data.variable = variable
    }
    await startProcess(params.id, data)
    handleCancel()
    emit('refresh');
    ElMessage.success('流程发起成功')
  } catch (error) {
    console.error('流程发起失败:', error)
  } finally {
    loading.value = false
  }
}

function collectFields(conditionNodes) {
    const collect = {};

    if (!Array.isArray(conditionNodes)) return collect;

    conditionNodes
        .forEach(conditionNode => {
            const conditionList = conditionNode.conditionList || [];
            conditionList.forEach(innerList => {
              (innerList || []).forEach(expression => {
                    if (expression && expression.field) {
                        if (!(expression.field in collect)) {
                            collect[expression.field] = 0;
                        }
                    }
                });
            });
        });

    return collect;
}

// 提供更新函数给所有子组件
provide('updateNodeConfig', (updateFn) => {
  modelContent.value.nodeConfig = updateFn(modelContent.value.nodeConfig);
});

// 初始化调用接口获取流程数据
watchEffect(async () => {
  console.log('props', props)
  var res = {}
  if(!props.businessKey) {
    res = await getProcessInfo(props.processKey)
  } else {
    res = await getInstanceModel(props.businessKey)
  }
  if (res) {
    const processModel = JSON.parse(res.modelContent);
    await traverseNode(processModel.nodeConfig);
    modelContent.value = processModel;
  }
});

const traverseNode = async (node) => {
  if (node?.childNode) {
    await traverseNode(node.childNode);
  }
  if (node?.type === 5) {
    const modelResult = await getProcessInfo(parseCallProcess(node.callProcess).id)
    const processModel = JSON.parse(modelResult.modelContent);
    await traverseNode(processModel.nodeConfig);
    node.nodeConfig = processModel.nodeConfig;
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
.workflow {
  max-width: 700px;
  margin-top: 20px;
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 8px;
}
</style>
