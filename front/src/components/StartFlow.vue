<template>
  <div class="workflow">
    <node-renderer :mode="mode" :node="modelContent.nodeConfig" />
  </div>
  <div class="modal-footer" v-if="mode === 'edit'">
    <el-button @click="handleCancel">取消</el-button>
    <el-button @click="handleSave">保存</el-button>
    <el-button type="primary" @click="handleSubmit">提交</el-button>
  </div>
</template>

<script setup>
import { defineProps, defineEmits, inject, provide, computed, watchEffect, watch, ref } from 'vue';
import { ElMessage } from 'element-plus'
import { getProcessInfo, getInstanceModel, saveProcess, startProcess } from '@/api/process'
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

const emit = defineEmits(['cancel'])

const modelContent = ref({})

const handleCancel = () => {
  emit('cancel')
}

const handleSave = async () => {
  try {
    // 1. 先调用父组件保存逻辑
    const parentResult = await props.onSave()
    // 2. 执行子组件保存逻辑
    const data = {
      processKey: props.processKey,
      modelContent: JSON.stringify(modelContent.value)
    }
    await saveProcess(parentResult.id, data)
    handleCancel()
    ElMessage.success('保存成功')
  } catch (error) {
    console.error('保存失败:', error)
  }
}

const handleSubmit = async () => {
  try {
    // 1. 先调用父组件提交逻辑
    const parentResult = await props.onSubmit()
    
    // 2. 执行子组件提交逻辑
    const data = {
      processKey: props.processKey,
      modelContent: JSON.stringify(modelContent.value)
    }
    await startProcess(parentResult.id, data)
    handleCancel()
    ElMessage.success('提交成功')
  } catch (error) {
    console.error('提交失败:', error)
  }
}

// 提供更新函数给所有子组件
provide('updateNodeConfig', (updateFn) => {
  modelContent.value.nodeConfig = updateFn(modelContent.value.nodeConfig);
});

// 初始化调用接口获取流程数据
watchEffect(async () => {
  console.log('props', props)
  const res = !props.businessKey ? await getProcessInfo(props.processKey) : await getInstanceModel(props.businessKey)
  if (res.code == 0) {
    modelContent.value = JSON.parse(res.data.modelContent || res.data)
  }
});

</script>

<style scoped>
.workflow {
  margin-top: 20px;
}

.modal-footer {
    display: flex;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 8px;
}
</style>
