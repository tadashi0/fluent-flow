<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #DD2626;">
        <el-icon class="icon"><el-icon-paperclip /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span v-if="displayRouteInfo">{{ displayRouteInfo }}</span>
        <span v-else class="placeholder">请设置路由节点</span>
      </div>
    </div>

    <add-node v-model="nodeConfig.childNode" />

    <el-drawer
      title="路由分支"
      v-model="drawer"
      destroy-on-close
      append-to-body
      :size="600"
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
        <el-main style="padding: 0 20px 20px 20px;">
          <el-form label-position="top">
            <div v-for="(routeNode, routeIndex) in form.routeNodes" :key="routeNode.nodeKey || routeIndex" class="route-branch-item">
              <div class="route-header">
                <div class="route-title-group">
                  <label @click="editRouteTitle(routeIndex)" v-if="editingRouteIndex !== routeIndex">
                    {{ routeNode.nodeName }}
                    <el-icon class="route-edit-icon">
                      <el-icon-edit />
                    </el-icon>
                  </label>
                  <el-input
                    v-if="editingRouteIndex === routeIndex"
                    :ref="el => routeTitleRefs[routeIndex] = el"
                    v-model="routeNode.nodeName"
                    clearable
                    @blur="saveRouteTitle"
                    @keyup.enter="saveRouteTitle"
                  />
                </div>
                <el-icon
                  class="route-delete-icon"
                  @click="deleteRoute(routeIndex)"
                  v-if="form.routeNodes.length > 1"
                >
                  <el-icon-delete />
                </el-icon>
              </div>

              <el-form-item>
                <el-select
                  v-model="routeNode.nodeKey"
                  placeholder="请选择流程节点"
                  style="width: 100%;"
                  clearable
                >
                  <el-option
                    v-for="node in availableNodes"
                    :key="node.nodeKey"
                    :label="node.nodeName"
                    :value="node.nodeKey"
                  />
                </el-select>
              </el-form-item>

              <div class="top-tips">满足以下条件时进入当前分支</div>

              <template v-for="(conditionGroup, conditionGroupIdx) in routeNode.conditionList" :key="conditionGroupIdx">
                <div class="or-branch-link-tip" v-if="conditionGroupIdx !== 0">或满足</div>

                <div class="condition-group-editor">
                  <div class="header">
                    <span>条件组 {{ conditionGroupIdx + 1 }}</span>
                    <div @click="deleteConditionGroup(routeNode, conditionGroupIdx)">
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
                            placeholder="自定义条件字段"
                            @change="val => syncLabel(condition, val)"
                          >
                            <el-option
                              v-for="item in fieldOptions"
                              :key="item.field"
                              :label="item.label"
                              :value="item.field"
                            />
                          </el-select>
                          <el-select v-model="condition.operator" placeholder="等于">
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
                      添加自定义条件
                    </el-button>
                  </div>
                </div>
              </template>

              <el-button style="width: 100%" type="info" icon="el-icon-plus" text bg @click="addConditionGroup(routeNode)">
                添加条件组
              </el-button>

              <el-divider v-if="routeIndex < form.routeNodes.length - 1" />
            </div>

            <el-button style="width: 100%; margin-top: 20px;" type="primary" icon="el-icon-plus" @click="addRouteBranch">
              添加路由分支
            </el-button>
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, computed, nextTick, inject } from 'vue'
import AddNode from './addNode.vue'
import { getTableFields } from '@/api/process'

const props = defineProps({
  modelValue: { type: Object, default: () => ({}) },
  availableNodes: { type: Array, default: () => [] }
})
const emit = defineEmits(['update:modelValue'])
const nodeConfig = ref({})
const drawer = ref(false)
const form = ref({})
const isEditTitle = ref(false)
const nodeTitle = ref(null)
const editingRouteIndex = ref(-1)
const routeTitleRefs = ref([])
const fieldOptions = ref([])
const injectedTableName = inject('tableName', ref(''))

const displayRouteInfo = computed(() => {
  const { routeNodes } = nodeConfig.value
  if (!routeNodes || routeNodes.length === 0) return null
  const routeCount = routeNodes.length
  const totalConditions = routeNodes.reduce((sum, route) => {
    return sum + (route.conditionList ? route.conditionList.reduce((groupSum, group) => groupSum + group.length, 0) : 0)
  }, 0)
  return `${routeCount} 个路由分支，${totalConditions} 个条件`
})

watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal
}, { immediate: true })

watch(injectedTableName, async (newVal) => {
  if (newVal) {
    try {
      const res = await getTableFields(newVal)
      fieldOptions.value = res.data || []
    } catch (error) {
      console.error('获取表字段失败:', error)
      fieldOptions.value = []
    }
  }
}, { immediate: true })

function syncLabel(condition, fieldVal) {
  const match = fieldOptions.value.find(item => item.field === fieldVal)
  if (match) condition.label = match.label
}

const show = () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value))
  form.value.routeNodes?.forEach((route, index) => {
    if (!route.conditionList) route.conditionList = []
    if (!route.nodeKey) route.nodeKey = ''
    if (!route.priorityLevel) route.priorityLevel = index + 1
  })
  drawer.value = true
}

const editTitle = () => {
  isEditTitle.value = true
  nextTick(() => nodeTitle.value?.focus())
}
const saveTitle = () => { isEditTitle.value = false }
const editRouteTitle = (index) => {
  editingRouteIndex.value = index
  nextTick(() => routeTitleRefs.value[index]?.focus())
}
const saveRouteTitle = () => { editingRouteIndex.value = -1 }
const save = () => emit('update:modelValue', form.value)
const delNode = () => emit('update:modelValue', nodeConfig.value.childNode)

const addRouteBranch = () => {
  const newRouteIndex = form.value.routeNodes.length + 1
  const newRoute = {
    nodeName: `路由${newRouteIndex}`,
    nodeKey: '',
    priorityLevel: newRouteIndex,
    conditionMode: 1,
    conditionList: []
  }
  form.value.routeNodes.push(newRoute)
}

const deleteRoute = (index) => {
  if (form.value.routeNodes.length > 1) {
    form.value.routeNodes.splice(index, 1)
    form.value.routeNodes.forEach((route, idx) => {
      route.priorityLevel = idx + 1
      route.nodeName = `路由${idx + 1}`
    })
  }
}

function addConditionList(group) {
  group.push({ label: '', field: '', operator: '==', value: '' })
}
function deleteConditionList(group, idx) {
  group.splice(idx, 1)
}
function addConditionGroup(routeNode) {
  const group = []
  addConditionList(group)
  routeNode.conditionList.push(group)
}
function deleteConditionGroup(routeNode, idx) {
  routeNode.conditionList.splice(idx, 1)
}
</script>

<style scoped lang="scss">
::v-deep .el-input .el-input__inner {
  line-height: var(--el-input-inner-height) !important;
}

.route-branch-item {
  margin-bottom: 24px;
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  background-color: #fafafa;
}

.route-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  
  .route-title-group {
    display: flex;
    align-items: center;
    gap: 8px;
    
    label {
      display: flex;
      align-items: center;
      cursor: pointer;
      font-size: 16px;
      font-weight: 600;
      color: #303133;
      
      .route-edit-icon {
        margin-left: 8px;
        font-size: 14px;
        color: #409eff;
      }
    }
  }
  
  .route-delete-icon {
    cursor: pointer;
    color: #909399;
    font-size: 16px;
    
    &:hover {
      color: #f56c6c;
    }
  }
}

.top-tips {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  color: #646a73;
  font-size: 14px;
}

.or-branch-link-tip {
  margin: 10px 0;
  color: #646a73;
  font-size: 14px;
}

.condition-group-editor {
  user-select: none;
  border-radius: 4px;
  border: 1px solid #e4e5e7;
  position: relative;
  margin-bottom: 16px;
  background-color: white;

  .branch-delete-icon {
    font-size: 18px;
    cursor: pointer;
    color: #909399;
    
    &:hover {
      color: #f56c6c;
    }
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

.placeholder {
  color: #c0c4cc;
}

</style>