<template>
  <div class="node-wrap">
    <div class="node-wrap-box">
      <div class="title" style="background: #67C23A;">
        <el-icon class="icon"><el-icon-circle-check-filled /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span>自动通过</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode" />
  </div>
</template>

<script setup>
import { ref,watch} from 'vue'
import AddNode from './addNode.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['update:modelValue'])

// 响应式状态
const nodeConfig = ref({})

watch(() => props.modelValue, () => {
  nodeConfig.value = props.modelValue;
}, { immediate: true });


const delNode = () => {
  emit('update:modelValue', nodeConfig.value.childNode)
}

</script>

<style scoped>
</style>