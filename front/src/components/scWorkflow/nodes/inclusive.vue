<template>
  <div class="branch-wrap">
    <div class="branch-box-wrap">
      <div class="branch-box">
        <el-button class="add-branch" plain round @click="addTerm">
          添加条件
        </el-button>

        <div class="col-box" v-for="(item, index) in nodeConfig.inclusiveNodes" :key="index">
          <div class="condition-node">
            <div class="condition-node-box">
              <div class="auto-judge" @click="isDefaultCondition(index) ? null : show(index)">
                <div class="sort-left" v-if="index !== 0 && !isDefaultCondition(index)" @click.stop="arrTransfer(index, -1)">
                  <el-icon><el-icon-arrow-left /></el-icon>
                </div>
                <div class="title">
                  <span class="node-title9" :class="{ 'default-condition': isDefaultCondition(index) }">{{ item.nodeName }}</span>
                  <el-icon class="copy" v-if="!isDefaultCondition(index)" @click.stop="copyNode(index)" >
                    <el-icon-copy-document />
                  </el-icon>
                  <el-icon class="close" v-if="!isDefaultCondition(index)" @click.stop="delTerm(index)">
                    <el-icon-close />
                  </el-icon>
                </div>
                <div class="content">
                  <span v-if="toText(index)">{{ toText(index) }}</span>
                  <span v-else class="placeholder">{{ isDefaultCondition(index) ? '默认条件' : '请设置条件' }}</span>
                </div>
                <div class="sort-right" v-if="index !== nodeConfig.inclusiveNodes.length - 1 && !isDefaultCondition(index+1)" @click.stop="arrTransfer(index)">
                  <el-icon><el-icon-arrow-right /></el-icon>
                </div>
              </div>
              <add-node v-model="item.childNode" />
            </div>
          </div>

          <slot v-if="item.childNode" :node="item"></slot>

          <div class="top-left-cover-line" v-if="index === 0"></div>
          <div class="bottom-left-cover-line" v-if="index === 0"></div>
          <div class="top-right-cover-line" v-if="index === nodeConfig.inclusiveNodes.length - 1"></div>
          <div class="bottom-right-cover-line" v-if="index === nodeConfig.inclusiveNodes.length - 1"></div>
        </div>
      </div>
      <add-node v-model="nodeConfig.childNode" />
    </div>

    <el-drawer
      title="条件设置"
      v-model="drawer"
      destroy-on-close
      append-to-body
      :size="600"
      @close="save"
    >
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">{{form.nodeName}}<el-icon class="node-wrap-drawer__title-edit"><el-icon-edit /></el-icon></label>
          <el-input v-if="isEditTitle" ref="nodeTitle" v-model="form.nodeName" clearable @blur="saveTitle" @keyup.enter="saveTitle"></el-input>
        </div>
      </template>

      <el-container>
        <el-main style="padding: 0 20px 20px 20px">
          <div class="top-tips">满足以下条件时进入当前分支</div>

          <template v-for="(conditionGroup, conditionGroupIdx) in form.conditionList" :key="conditionGroupIdx">
            <div class="or-branch-link-tip" v-if="conditionGroupIdx !== 0">或满足</div>

            <div class="condition-group-editor">
              <div class="header">
                <span>条件组 {{ conditionGroupIdx + 1 }}</span>
                <div @click="deleteConditionGroup(conditionGroupIdx)">
                  <el-icon class="branch-delete-icon"><el-icon-delete /></el-icon>
                </div>
              </div>

              <div class="main-content">
                <div class="condition-content-box cell-box">
                  <div>条件字段</div>
                  <div>运算符</div>
                  <div>值</div>
                </div>

                <div v-for="(condition, idx) in conditionGroup" :key="idx" class="condition-content">
                  <div class="condition-relation">
                    <span>{{ idx === 0 ? '当' : '且' }}</span>
                    <div @click="deleteConditionList(conditionGroup, idx)">
                      <el-icon class="branch-delete-icon"><el-icon-delete /></el-icon>
                    </div>
                  </div>
                  <div class="condition-content">
                    <div class="condition-content-box">
                      <el-select
                        v-model="condition.field"
                        placeholder="条件字段"
                        @change="val => syncLabel(condition, val)"
                      >
                        <el-option
                          v-for="item in fieldOptions"
                          :key="item.field"
                          :label="item.label"
                          :value="item.field"
                        />
                      </el-select>
                      <el-select v-model="condition.operator" placeholder="Select">
                        <el-option label="等于" value="==" />
                        <el-option label="不等于" value="!=" />
                        <el-option label="大于" value=">" />
                        <el-option label="大于等于" value=">=" />
                        <el-option label="小于" value="<" />
                        <el-option label="小于等于" value="<=" />
                        <el-option label="包含" value="include" />
                        <el-option label="不包含" value="notinclude" />
                      </el-select>
                      <el-input v-model="condition.value" placeholder="值" />
                    </div>
                  </div>
                </div>
              </div>

              <div class="sub-content">
                <el-button link type="primary" @click="addConditionList(conditionGroup)" icon="el-icon-plus">
                  添加条件
                </el-button>
              </div>
            </div>
          </template>

          <el-button style="width: 100%" type="info" icon="el-icon-plus" text bg @click="addConditionGroup">
            添加条件组
          </el-button>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, inject, nextTick } from 'vue'
import addNode from './addNode.vue'
import { getTableFields } from '@/api/process'

const props = defineProps({
  modelValue: { type: Object, default: () => ({}) }
})

const emit = defineEmits(['update:modelValue'])

const nodeConfig = ref({})
const drawer = ref(false)
const isEditTitle = ref(false)
const index = ref(0)
const form = ref({})
const nodeTitle = ref(null)


const fieldOptions = ref([])

const injectedTableName = inject('tableName', ref(''))

watch(injectedTableName, async (newVal) => {
  if (newVal) {
    const res = await getTableFields(newVal)
    fieldOptions.value = res.data || []
  }
}, { immediate: true })

function syncLabel(condition, fieldVal) {
  const match = fieldOptions.value.find(item => item.field === fieldVal)
  if (match) {
    condition.label = match.label
  }
}

// 初始值同步
watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal
}, { immediate: true })

// 判断是否为默认条件
function isDefaultCondition(index) {
  const node = nodeConfig.value.inclusiveNodes?.[index]
  return node && node.nodeName === "默认条件"
}

function show(i) {
  if (isDefaultCondition(i)) return
  
  index.value = i
  form.value = JSON.parse(JSON.stringify(nodeConfig.value.inclusiveNodes?.[i]))
  drawer.value = true
}

function editTitle() {
  isEditTitle.value = true
  nextTick(() => nodeTitle.value?.focus())
}

function saveTitle() {
  isEditTitle.value = false
}

function save() {
  nodeConfig.value.inclusiveNodes[index.value] = JSON.parse(JSON.stringify(form.value))
  emit('update:modelValue', nodeConfig.value)
}

function addTerm() {
  const len = nodeConfig.value.inclusiveNodes.length
  
  // 添加在默认条件之前
  const newNode = {
    nodeName: '条件' + len,
    nodeKey: Date.now().toString(),
    type: 3,
    priorityLevel: len,
    conditionMode: 1,
    conditionList: []
  }
  
  // 如果有默认条件，插入到默认条件之前
  const defaultIndex = nodeConfig.value.inclusiveNodes.findIndex(node => node.nodeName === "默认条件")
  if (defaultIndex > 0) {
    nodeConfig.value.inclusiveNodes.splice(defaultIndex, 0, newNode)
  } else {
    // 否则添加在最后
    nodeConfig.value.inclusiveNodes.push(newNode)
  }
  
  // 更新优先级
  nodeConfig.value.inclusiveNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
}

function copyNode(i) {
  const nodeToCopy = JSON.parse(JSON.stringify(nodeConfig.value.inclusiveNodes[i]))
  
  // 复制节点，修改名称和Key
  const newNode = {
    ...nodeToCopy,
    nodeName: `${nodeToCopy.nodeName}_copy`,
    nodeKey: Date.now().toString(),
    priorityLevel: i + 2 // 设置为当前节点的下一个优先级
  }
  
  // 在当前节点后插入复制的节点
  nodeConfig.value.inclusiveNodes.splice(i + 1, 0, newNode)
  
  // 更新后续节点的优先级
  nodeConfig.value.inclusiveNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
  
  emit('update:modelValue', nodeConfig.value)
}

function delTerm(i) {  
  nodeConfig.value.inclusiveNodes.splice(i, 1)
  
  // 更新优先级
  nodeConfig.value.inclusiveNodes.forEach((item, idx) => {
    item.priorityLevel = idx + 1
  })
  
  if (nodeConfig.value.inclusiveNodes.length === 1 && nodeConfig.value.childNode) {
    if (nodeConfig.value.inclusiveNodes[0].childNode) {
      reData(nodeConfig.value.inclusiveNodes[0].childNode, nodeConfig.value.childNode)
    } else {
      nodeConfig.value.inclusiveNodes[0].childNode = nodeConfig.value.childNode
    }
    emit('update:modelValue', nodeConfig.value.inclusiveNodes[0].childNode)
  }
}

function reData(data, addData) {
  if (!data.childNode) {
    data.childNode = addData
  } else {
    reData(data.childNode, addData)
  }
}

function arrTransfer(i, type = 1) {
  const targetIndex = i + type
  
  // 不允许移动默认条件或将其他条件移动到默认条件之后
  if (isDefaultCondition(i) || (targetIndex === 1 && type === -1)) return
  
  // 不允许把条件移到默认条件的位置
  if (isDefaultCondition(targetIndex)) return
  
  const moved = nodeConfig.value.inclusiveNodes.splice(i, 1)[0]
  nodeConfig.value.inclusiveNodes.splice(targetIndex, 0, moved)
  nodeConfig.value.inclusiveNodes.forEach((item, idx) => (item.priorityLevel = idx + 1))
  emit('update:modelValue', nodeConfig.value)
}

function addConditionList(group) {
  group.push({
    label: '',
    field: '',
    operator: '==',
    value: ''
  })
}

function deleteConditionList(group, idx) {
  group.splice(idx, 1)
}

function addConditionGroup() {
  const group = []
  addConditionList(group)
  form.value.conditionList.push(group)
}

function deleteConditionGroup(idx) {
  form.value.conditionList.splice(idx, 1)
}

function toText(i) {
  if (isDefaultCondition(i)) {
    return '未满足其他条件时，将进入默认流程'
  }
  
  const conditionList = nodeConfig.value.inclusiveNodes?.[i].conditionList
  if (conditionList?.length === 1) {
    return conditionList.map(group => group.map(item => `${item.label}${item.operator}${item.value}`).join(' 和 ')).join(' 或 ')
  } else if (conditionList?.length > 1) {
    return `${conditionList.length}个条件，或满足`
  }
  return false
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

.default-condition {
  color: #909399 !important;
}
</style>
