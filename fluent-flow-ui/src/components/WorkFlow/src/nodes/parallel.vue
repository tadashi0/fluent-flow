<template>
  <div class="branch-wrap">
    <div class="branch-box-wrap">
      <div class="branch-box">
        <el-button class="add-branch" plain round @click="addTerm">
          添加分支
        </el-button>

        <div class="col-box" v-for="(item, index) in nodeConfig.parallelNodes" :key="index">
          <div class="condition-node">
            <div class="condition-node-box">
              <div class="auto-judge">
                <div class="sort-left" v-if="index !== 0" @click.stop="arrTransfer(index, -1)">
                  <el-icon><el-icon-arrow-left /></el-icon>
                </div>
                <div class="title">
                  <span class="node-title8">{{ item.nodeName }}</span>
                  <span class="priority-title">并行执行</span>
                  <el-icon class="copy" @click.stop="copyNode(index)">
                    <el-icon-copy-document />
                  </el-icon>
                  <el-icon class="close" @click.stop="delTerm(index)">
                    <el-icon-close />
                  </el-icon>
                </div>
                <div class="content">
                  <span>并行任务（同时进行）</span>
                </div>
                <div class="sort-right" v-if="index !== nodeConfig.parallelNodes.length - 1" @click.stop="arrTransfer(index)">
                  <el-icon><el-icon-arrow-right /></el-icon>
                </div>
              </div>
              <add-node v-model="item.childNode" />
            </div>
          </div>

          <slot v-if="item.childNode" :node="item"></slot>

          <div class="top-left-cover-line" v-if="index === 0"></div>
          <div class="bottom-left-cover-line" v-if="index === 0"></div>
          <div class="top-right-cover-line" v-if="index === nodeConfig.parallelNodes.length - 1"></div>
          <div class="bottom-right-cover-line" v-if="index === nodeConfig.parallelNodes.length - 1"></div>
        </div>
      </div>
      <add-node v-model="nodeConfig.childNode" />
    </div>
  </div>
</template>

<script setup>
import { ref, watch, inject } from 'vue'
import addNode from './addNode.vue'
import { getTableFields } from '@/api/workflow'

const props = defineProps({
  modelValue: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['update:modelValue'])

const nodeConfig = ref({})
const fieldOptions = ref([])

const injectedTableName = inject('tableName', ref(''))

const loading = ref(false)

watch(injectedTableName, async (newVal) => {
  if (newVal) {
    loading.value = true
    try {
      const res = await getTableFields(newVal)
      fieldOptions.value = res || []
    } finally {
      loading.value = false
    }
  }
}, { immediate: true })

// 初始值同步
watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal
}, { immediate: true })

function copyNode(i) {
  const nodeToCopy = JSON.parse(JSON.stringify(nodeConfig.value.parallelNodes[i]))
  
  // 复制节点，修改名称和Key
  const newNode = {
    ...nodeToCopy,
    nodeName: `${nodeToCopy.nodeName}_copy`,
    nodeKey: Date.now().toString(),
    priorityLevel: i + 2 // 设置为当前节点的下一个优先级
  }
  
  // 在当前节点后插入复制的节点
  nodeConfig.value.parallelNodes.splice(i + 1, 0, newNode)
  
  // 更新后续节点的优先级
  nodeConfig.value.parallelNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
  
  emit('update:modelValue', nodeConfig.value)
}

function addTerm() {
  const len = nodeConfig.value.parallelNodes.length
  
  // 创建新节点
  const newNode = {
    nodeName: '并行分支' + (len + 1),
    nodeKey: Date.now().toString(),
    type: 3,
    priorityLevel: len + 1,
    conditionMode: 1,
    conditionList: []
  }
  
  // 添加到末尾
  nodeConfig.value.parallelNodes.push(newNode)
  
  // 更新优先级
  nodeConfig.value.parallelNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
  
  emit('update:modelValue', nodeConfig.value)
}

function delTerm(i) {  
  nodeConfig.value.parallelNodes.splice(i, 1)
  
  // 更新优先级
  nodeConfig.value.parallelNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
  
  // 如果删除后只剩下默认条件，清空整个条件分支数据
  if (nodeConfig.value.parallelNodes.length === 1) {
    
    // 清空默认条件的子节点
    nodeConfig.value.parallelNodes[0].childNode = null
    
    // 如果条件分支后面还有节点，将其作为新的子节点返回
    if (nodeConfig.value.childNode) {
      emit('update:modelValue', nodeConfig.value.childNode)
    } else {
      // 如果没有后续节点，返回null或空对象
      emit('update:modelValue', null)
    }
  } else {
    // 正常情况下更新数据
    emit('update:modelValue', nodeConfig.value)
  }
}

function arrTransfer(i, type = 1) {
  const targetIndex = i + type
  
  // 不允许移动超出范围
  if (targetIndex < 0 || targetIndex >= nodeConfig.value.parallelNodes.length) return
  
  const moved = nodeConfig.value.parallelNodes.splice(i, 1)[0]
  nodeConfig.value.parallelNodes.splice(targetIndex, 0, moved)
  nodeConfig.value.parallelNodes.forEach((item, idx) => (item.priorityLevel = idx + 1))
  emit('update:modelValue', nodeConfig.value)
}
</script>

<style scoped lang="scss">
.top-tips {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  color: #646a73;
}

.or-branch-link-tip {
  margin: 10px 0;
  color: #646a73;
}

.condition-group-editor {
  user-select: none;
  border-radius: 4px;
  border: 1px solid #e4e5e7;
  position: relative;
  margin-bottom: 16px;

  .branch-delete-icon {
    font-size: 18px;
  }

  .header {
    background-color: #f4f6f8;
    padding: 0 12px;
    font-size: 14px;
    color: #171e31;
    height: 36px;
    display: flex;
    align-items: center;

    span {
      flex: 1;
    }
  }

  .main-content {
    padding: 0 12px;

    .condition-relation {
      color: #9ca2a9;
      display: flex;
      align-items: center;
      height: 36px;
      display: flex;
      justify-content: space-between;
      padding: 0 2px;
    }

    .condition-content-box {
      display: flex;
      justify-content: space-between;
      align-items: center;

      div {
        width: 100%;
        min-width: 120px;
      }

      div:not(:first-child) {
        margin-left: 16px;
      }
    }

    .cell-box {
      div {
        padding: 16px 0;
        width: 100%;
        min-width: 120px;
        color: #909399;
        font-size: 14px;
        font-weight: 600;
        text-align: center;
      }
    }

    .condition-content {
      display: flex;
      flex-direction: column;

      :deep(.el-input__wrapper) {
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
      }

      .content {
        flex: 1;
        padding: 0 0 4px 0;
        display: flex;
        align-items: center;
        min-height: 31.6px;
        flex-wrap: wrap;
      }
    }
  }

  .sub-content {
    padding: 12px;
  }
}

</style>
