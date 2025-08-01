<template>
  <el-affix :offset="16" style="height: 74px; width: 100%">
    <div class="btn-container">
      <div class="zoom-control">
        <el-button :icon="Minus" circle @click="decreaseZoom" />
        <span class="zoom-percentage">{{ Math.round(zoom * 100) }}%</span>
        <el-button :icon="Plus" circle @click="increaseZoom" />
      </div>
    </div>
  </el-affix>
  <div class="affix-container" :style="`transform: scale(${zoom}); transform-origin: 50% 0`">
    <sc-workflow class="workflow" ref="workflowRef" id="content-to-capture" v-model="data.nodeConfig" />
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import {Minus, Plus } from '@element-plus/icons-vue'
import scWorkflow from '@/components/WorkFlow/src/index.vue'

const props = defineProps({
  processKey: {
    type: String,
    required: true
  },
  processName: {
    type: String,
    required: true
  },
  module: {
    type: String,
    required: true
  },
  modelContent: {
    type: Object,
    default: null
  }
})

// 缩放控制
const zoom = ref(1)
// 增加和减少缩放的方法
const increaseZoom = () => {
  if (zoom.value < 5) {
    zoom.value = Math.min(5, zoom.value + 0.05)
  }
}
const decreaseZoom = () => {
  if (zoom.value > 0.1) {
    zoom.value = Math.max(0.1, zoom.value - 0.05)
  }
}

// 流程数据
const defaultData = computed(() => ({
  name: props.processName,
  key: props.processKey,
  module: props.module,
  nodeConfig: {
    nodeName: "发起人",
    nodeKey: "flk001",
    type: 0,
    nodeAssigneeList: [],
    childNode: {
      nodeName: "审批人1",
      nodeKey: "flk002",
      type: 1,
      setType: 4,
      examineLevel: 1,
      examineMode: 1,
      directorLevel: 1,
      directorMode: 0,
      selectMode: 1,
      remind: true,
      termAuto: false,
      term: 0,
      termMode: 1,
			approveSelf: 0,		
      childNode: {
        nodeName: "审批人2",
        nodeKey: "flk003",
        type: 1,
        setType: 4,
        examineLevel: 1,
        examineMode: 1,
        directorLevel: 1,
        directorMode: 0,
        selectMode: 1,
        remind: true,
        termAuto: false,
        term: 0,
        termMode: 1,
        approveSelf: 0,		
        childNode: {
          nodeName: '结束',
          nodeKey: "flk004",
          type: -1
        },
      }
    }
  }
}))

const data = ref(defaultData.value)

watch(() => props.modelContent, (newContent) => {
  if (newContent) {
    data.value = JSON.parse(newContent)
  } else {
    data.value = defaultData.value
  }
}, { immediate: true })

// 组件引用
const workflowRef = ref(null)

// 暴露方法
const getWorkflowData = () => {
  return data.value
}

defineExpose({
  getWorkflowData
})
</script>

<style>
:root {
  --el-drawer-padding-primary: 0;
}

body {
  margin: 0;
  background-color: #efefef;
}

.affix-container {
  display: flex;
  justify-content: center;
  flex-direction: row-reverse;
  overflow: auto;
  height: calc(100vh - 100px);
  overflow: visible;
}

.editor {
  width: 500px;
  height: calc(100vh - 36px);
}

.editor .jsoneditor-poweredBy,
.editor .jsoneditor-transform,
.editor .jsoneditor-repair,
.editor .full-screen {
  display: none !important;
}

.workflow {
  padding: 10px;
}

.jsoneditor-menu>button.jsoneditor-copy {
  background-position: -48px 0px;
}

.el-drawer__body {
  padding: 0 !important;
}

.btn-container {
  display: flex;
  height: 42px;
  margin-left: 16px;
  justify-content: flex-end;
}

/* .zoom-control {
  display: flex;
  align-items: center;
  margin-right: 16px;
  border-radius: 20px;
  padding: 4px 8px;
} */
.zoom-control {
  display: flex;
  align-items: center;
  margin-right: 16px;
  border-radius: 20px;
  padding: 4px 8px;
  position: fixed;
  right: 16px;
  z-index: 1000;

  .el-button:not(.el-button--primary):not(.is-link) {
    cursor: pointer;
    font-size: 0.875rem;
    transition: 0.3s;
    height: 2rem;
    line-height: 2rem;
    border: 0;
  }
  
  .el-button.is-circle {
    color: var(--el-button-text-color);
    background-color: var(--el-button-bg-color);
    border-radius: 50%;
    padding: 8px;
    width: 32px;
}
}



.zoom-percentage {
  margin: 0 10px;
  font-size: 16px;
  min-width: 40px;
  text-align: center;
}
</style>
