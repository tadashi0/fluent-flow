<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #9260FB;">
        <el-icon class="icon"><el-icon-connection /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span v-if="processName">{{ processName }}</span>
        <span v-else class="placeholder">请选择子流程规则</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode" />
    
    <!-- 设置抽屉 -->
    <el-drawer 
      title="子流程设置" 
      v-model="drawer" 
      destroy-on-close 
      append-to-body 
      :size="500"
      @closed="save"
    >
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">
            {{ form.nodeName }}
            <el-icon class="node-wrap-drawer__title-edit">
              <el-icon-edit />
            </el-icon>
          </label>
          <el-input 
            v-if="isEditTitle" 
            ref="nodeTitle" 
            v-model="form.nodeName" 
            clearable 
            @blur="saveTitle"
            @keyup.enter="saveTitle"
          />
        </div>
      </template>

      <el-container>
        <el-main style="padding:0 20px 20px 20px">
          <el-form label-position="top">
            <el-form-item label="选择子流程">
              <el-select
                v-model="selectedProcessId"
                filterable
                placeholder="请选择子流程"
                :loading="loading"
                style="width: 100%"
                @change="handleProcessChange"
              >
                <el-option
                  v-for="item in processList"
                  :key="item.id"
                  :label="item.processName"
                  :value="String(item.id)"
                />
              </el-select>
            </el-form-item>
            
            <el-form-item v-if="selectedProcessId">
              <el-button 
                type="primary" 
                :icon="View" 
                @click="handlePreview"
              >
                预览子流程
              </el-button>
            </el-form-item>
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>

    <!-- 预览对话框 -->
    <el-dialog 
      v-model="previewVisible" 
      title="子流程预览" 
      width="800px" 
      append-to-body
      destroy-on-close
    >
      <preview-flow 
        v-if="previewVisible"
        :flow-data="previewFlowData"
        v-model:process-name="previewProcessName"
        v-model:remark="previewRemark"
      />
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, watch, onMounted } from 'vue'
import { View } from '@element-plus/icons-vue'
import { getProcessList } from '@/api/process'
import AddNode from './addNode.vue'
import PreviewFlow from '@/components/PreviewFlow.vue'

const props = defineProps({
  modelValue: { 
    type: Object,
    default: () => ({
      nodeName: '子流程',
      callProcess: '',
      childNode: null
    })
  }
})

const emit = defineEmits(['update:modelValue'])

// 响应式状态
const nodeConfig = ref({...props.modelValue})
const drawer = ref(false)
const isEditTitle = ref(false)
const form = ref({})
const nodeTitle = ref(null)
const loading = ref(false)
const processList = ref([])
const selectedProcessId = ref(null)

// 预览相关
const previewVisible = ref(false)
const previewFlowData = ref({})
const previewProcessName = ref('')
const previewRemark = ref('')

// 计算属性
const processName = computed(() => {
  if (!nodeConfig.value.callProcess) return null
  const parts = nodeConfig.value.callProcess.split(':')
  return parts.length > 1 ? parts[1] : null
})

// 生命周期
onMounted(() => {
  initProcessData()
  fetchProcessList()
})

// 方法
const initProcessData = () => {
  if (nodeConfig.value.callProcess) {
    const parts = nodeConfig.value.callProcess.split(':')
    if (parts.length > 0) {
      selectedProcessId.value = String(parts[0])
    }
  } else {
    selectedProcessId.value = null
  }
}

const show = async () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value))
  drawer.value = true
  await fetchProcessList() // 每次打开都刷新流程列表
}

const editTitle = () => {
  isEditTitle.value = true
  nextTick(() => nodeTitle.value?.focus())
}

const saveTitle = () => {
  isEditTitle.value = false
}

const save = () => {
  if (selectedProcessId.value) {
    const process = processList.value.find(
      item => String(item.id) === selectedProcessId.value
    )
    form.value.callProcess = process ? `${process.id}:${process.processName}` : ''
  }
  emit('update:modelValue', form.value)
}

const delNode = () => {
  emit('update:modelValue', nodeConfig.value.childNode)
}

const fetchProcessList = async () => {
  try {
    loading.value = true
    const res = await getProcessList({
      processKey: form.value.key,
      size: -1,
      useScope: 1,
    })
    processList.value = res.data.records || []
    validateSelectedProcess()
  } catch (error) {
    console.error('流程加载失败:', error)
    processList.value = []
    selectedProcessId.value = null
  } finally {
    loading.value = false
  }
}

const validateSelectedProcess = () => {
  if (selectedProcessId.value) {
    const exists = processList.value.some(
      item => String(item.id) === selectedProcessId.value
    )
    if (!exists) selectedProcessId.value = null
  }
}

const handleProcessChange = (id) => {
  const process = processList.value.find(
    item => String(item.id) === id
  )
  form.value.callProcess = process ? `${process.id}:${process.processName}` : ''
}

const handlePreview = () => {
  const process = processList.value.find(
    item => String(item.id) === selectedProcessId.value
  )
  if (process) {
    try {
      previewFlowData.value = JSON.parse(process.modelContent)
      previewProcessName.value = process.processName
      previewRemark.value = process.remark || ''
      previewVisible.value = true
    } catch (e) {
      console.error('流程数据解析失败:', e)
      ElMessage.error('流程数据格式错误')
    }
  }
}

// 监听器
watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = {...newVal}
  initProcessData()
})

watch(processList, validateSelectedProcess)
</script>

<style scoped>
</style>