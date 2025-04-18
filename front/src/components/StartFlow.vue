<template>
  <div class="modal">
    <div class="modal-body">
      <div class="workflow">
        <node-renderer :mode="mode" :node="flowData.nodeConfig" />
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps, provide, computed, watchEffect, watch } from 'vue';
import { getProcessInfo, getInstanceModel } from '@/api/process'
import NodeRenderer from './NodeRenderer.vue';

const props = defineProps({
  flowData: {
    type: Object,
    required: false,
  },
  processKey: String,
  businessKey: String,
  mode: {
    type: String,
    default: 'edit'
  }
});

// 提供更新函数给所有子组件
provide('updateFlowData', (updateFn) => {
  props.flowData.nodeConfig = updateFn(props.flowData.nodeConfig);
});

// 初始化调用接口获取流程数据
const emit = defineEmits(['update:flowData'])
watchEffect(async () => {
  const res = !props.businessKey ? await getProcessInfo(props.processKey) : await getInstanceModel(props.businessKey)
  if (res.code == 0) {
    emit('update:flowData', JSON.parse(res.data.modelContent || res.data))
  }
});

</script>

<style scoped>
.workflow {
  margin-top: 20px;
}
</style>
