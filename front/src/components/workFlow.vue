<template>
  <el-affix :offset="16" style="height: 74px; width: 100%">
    <div class="btn-container">
      <div class="slider">
        <el-button type="primary" icon="el-icon-minus" style="margin-right: 16px; width: 32px" @click="zoom -= 0.1" />
        <el-slider v-model="zoom" :marks="marks" :min="0.1" :max="5" :step="0.1" height="200px" />
        <el-button type="primary" icon="el-icon-plus" style="margin-left: 16px; width: 32px" @click="zoom += 0.1" />
      </div>
    </div>
  </el-affix>
  <div class="affix-container" :style="`transform: scale(${zoom})`" style="transform-origin: 0 0">
    <sc-workflow class="workflow" ref="workflowRef" id="content-to-capture" v-model="data.nodeConfig" />
  </div>
</template>
<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import scWorkflow from '@/components/scWorkflow/index.vue'

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
const marks = reactive({
  0.1: 'min',
  1: '1',
  2: '2',
  3: '3',
  4: '4',
  5: 'max'
})

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
      termAuto: false,
      term: 0,
      termMode: 1,
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
        termAuto: false,
        term: 0,
        termMode: 1
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
  return JSON.stringify(data.value)
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

.slider {
  width: 300px;
  display: flex;
  margin-left: 0;
  margin-right: 16px;
}
</style>
