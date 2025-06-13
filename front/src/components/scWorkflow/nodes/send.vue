<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #3296fa;">
        <el-icon class="icon"><Promotion /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode"><Close /></el-icon>
      </div>
      <div class="content">
        <span v-if="toText(nodeConfig)">{{ toText(nodeConfig) }}</span>
        <span v-else class="placeholder">请选择人员</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode"></add-node>
    <el-drawer 
      title="抄送人设置" 
      v-model="drawer" 
      destroy-on-close 
      append-to-body 
      :size="600" 
      @closed="save"
    >
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">{{ form.nodeName }}
            <el-icon class="node-wrap-drawer__title-edit"><Edit /></el-icon>
          </label>
          <el-input 
            v-if="isEditTitle" 
            ref="nodeTitleRef" 
            v-model="form.nodeName" 
            clearable 
            @blur="saveTitle"
            @keyup.enter="saveTitle"
          ></el-input>
        </div>
      </template>
      <el-container>
        <el-main style="padding:0 20px 20px 20px">
          <el-form label-position="top">
            <el-form-item label="选择要抄送的人员">
              <el-button type="primary" :icon="Plus" round @click="selectHandle(1, form.nodeAssigneeList)">
                选择人员
              </el-button>
              <div class="tags-list">
                <el-tag 
                  v-for="(user, index) in form.nodeAssigneeList" 
                  :key="user.id" 
                  closable
                  @close="delUser(index)"
                >
                  {{ user.name }}
                </el-tag>
              </div>
            </el-form-item>
            <el-form-item label="">
              <el-checkbox v-model="form.allowSelection" label="允许发起人自选抄送人"></el-checkbox>
            </el-form-item>
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, inject, watch, onMounted } from 'vue'
import { Edit, Close, Promotion, Plus } from '@element-plus/icons-vue'
import addNode from './addNode.vue'

// 属性定义
const props = defineProps({
  modelValue: { 
    type: Object, 
    default: () => ({}) 
  }
})

// 事件定义
const emit = defineEmits(['update:modelValue'])

// 注入依赖
const select = inject('select')

// 响应式数据
const nodeConfig = ref({})
const drawer = ref(false)
const isEditTitle = ref(false)
const form = ref({})
const nodeTitleRef = ref(null)

// 监听属性变化
watch(() => props.modelValue, () => {
  nodeConfig.value = props.modelValue
}, { immediate: true })

// 生命周期钩子
onMounted(() => {
  nodeConfig.value = props.modelValue
})

// 方法定义
const show = () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value))
  drawer.value = true
}

const editTitle = () => {
  isEditTitle.value = true
  nextTick(() => {
    nodeTitleRef.value.focus()
  })
}

const saveTitle = () => {
  isEditTitle.value = false
}

const save = () => {
  emit('update:modelValue', form.value)
  drawer.value = false
}

const delNode = () => {
  emit('update:modelValue', nodeConfig.value.childNode)
}

const delUser = (index) => {
  form.value.nodeAssigneeList.splice(index, 1)
}

const selectHandle = (type, data) => {
  select(type, data)
}

const toText = (nodeConfig) => {
  if (nodeConfig.nodeAssigneeList && nodeConfig.nodeAssigneeList.length > 0) {
    const users = nodeConfig.nodeAssigneeList.map(item => item.name).join('、')
    return users
  } else {
    if (nodeConfig.allowSelection) {
      return '发起人自选'
    } else {
      return false
    }
  }
}
</script>

<style>
/* 保留原有样式 */
</style>
