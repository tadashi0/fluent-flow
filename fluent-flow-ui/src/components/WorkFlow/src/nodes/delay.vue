<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #F55266;">
        <el-icon class="icon"><el-icon-clock /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span v-if="displayTime">{{ displayTime }}</span>
        <span v-else class="placeholder">请设置延时处理时间</span>
      </div>
    </div>

    <add-node v-model="nodeConfig.childNode" />

    <el-drawer
      title="延时处理设置"
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
        <el-main>
          <el-form label-position="top">
            <el-form-item label="延时方式">
              <el-radio-group v-model="delayType">
                <el-radio-button label="1">固定时长</el-radio-button>
                <el-radio-button label="2">自动计算</el-radio-button>
              </el-radio-group>
            </el-form-item>

            <!-- 固定时长输入项 -->
            <el-form-item v-if="delayType === '1'">
              <el-input
                type="number"
                v-model="fixedValue"
                style="max-width: 200px"
              >
                <template #append>
                  <el-select v-model="fixedUnit" style="width: 80px">
                    <el-option label="天" value="d" />
                    <el-option label="小时" value="h" />
                    <el-option label="分钟" value="m" />
                  </el-select>
                </template>
              </el-input>
              <span style="margin-left: 10px;">后进入下一步</span>
            </el-form-item>

            <!-- 自动计算时间 -->
            <el-form-item v-if="delayType === '2'">
              <el-time-picker
                v-model="autoTime"
                format="HH:mm:ss"
                value-format="HH:mm:ss"
                placeholder="时间点"
              />
              <span style="margin-left: 10px;">后进入下一步</span>
            </el-form-item>
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, computed, nextTick } from 'vue'
import AddNode from './addNode.vue'

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
})
const emit = defineEmits(['update:modelValue'])

const nodeConfig = ref({})
const drawer = ref(false)
const form = ref({})
const isEditTitle = ref(false)
const nodeTitle = ref(null)

const delayType = ref('1')
const fixedValue = ref(0)
const fixedUnit = ref('m')
const autoTime = ref('')

// 展示时间格式
const displayTime = computed(() => {
  const { delayType, extendConfig } = nodeConfig.value
  const time = extendConfig?.time
  if (!time) return null

  if (delayType === '1') {
    const map = { m: '分钟', h: '小时', d: '天' }
    const [val, unit] = time.split(':')
    return `等待 ${val} ${map[unit] || ''}`
  }
  return `至当天 ${time}`
})

// 初始值同步
watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal
}, { immediate: true })

// 打开抽屉并同步值
const show = () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value))
  delayType.value = form.value.delayType || '1'

  const time = form.value.extendConfig?.time
  if (delayType.value === '1' && time) {
    const [val, unit] = time.split(':')
    fixedValue.value = parseInt(val)
    fixedUnit.value = unit
  } else if (delayType.value === '2') {
    autoTime.value = time || ''
  }

  drawer.value = true
}

const editTitle = () => {
  isEditTitle.value = true
  nextTick(() => nodeTitle.value?.focus())
}

const saveTitle = () => {
  isEditTitle.value = false
}

const save = () => {
  form.value.delayType = delayType.value
  if (!form.value.extendConfig) form.value.extendConfig = {}

  if (delayType.value === '1') {
    form.value.extendConfig.time = `${fixedValue.value}:${fixedUnit.value}`
  } else if (delayType.value === '2') {
    form.value.extendConfig.time = autoTime.value
  }

  emit('update:modelValue', form.value)
}

const delNode = () => {
  emit('update:modelValue', nodeConfig.value.childNode)
}
</script>

<style scoped>
::v-deep .el-input .el-input__inner {
  line-height: var(--el-input-inner-height) !important;
}
</style>

