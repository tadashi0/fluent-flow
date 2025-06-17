<template>
    <!-- 流程容器组件 -->
    <div class="flow-container">
      <start-flow
        v-if="showStartFlow"
        :process-key="processKey"
        :business-key="businessKey"
        :mode="effectiveMode"
        :on-submit="onSubmit"
        :on-save="onSave"
        @cancel="handleCancel"
        @refresh="handleRefresh"
      />
      
      <approve-flow
        v-else
        :business-key="businessKey"
        :mode="effectiveMode"
        :on-approve="onApprove"
        @cancel="handleCancel"
        @refresh="handleRefresh"
      />
    </div>
</template>
  
<script setup>
import { computed } from 'vue'
import StartFlow from './StartFlow.vue'
import ApproveFlow from './ApproveFlow.vue'

const props = defineProps({
  processKey: {
    type: String,
    required: true
  },
  businessKey: [String, Number],
  status: {
    type: Number,
    default: 0
  },
  onRefresh: Function,
  onSubmit: Function,
  onSave: Function,
  onApprove: Function,
  readonly: Boolean
})

const emit = defineEmits(['cancel', 'refresh'])

const handleCancel = () => emit('cancel')
const handleRefresh = () => emit('refresh')

// 有效模式计算（处理只读覆盖）
const effectiveMode = computed(() => 
  props.readonly ? 'preview' : 'edit'
)

// 显示发起流程的条件
const showStartFlow = computed(() => {
  return [0, 4].includes(props.status) && 
    (props.readonly ? props.status === 0 : true)
})
</script>