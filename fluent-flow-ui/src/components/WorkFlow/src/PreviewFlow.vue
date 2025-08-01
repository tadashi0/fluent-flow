<template>
  <div class="modal">
    <div class="modal-body">
      <div class="form-group">
        <label class="form-label">模型名称</label>
        <input type="text" class="form-control" :value="processName" readonly>
      </div>
      
      <div class="form-group">
        <label class="form-label">模型描述</label>
        <textarea class="form-control" :value="remark" readonly />
        <div class="char-count" v-if="remark">{{ remark.length }} / 200</div>
      </div>
      
      <div class="process-info">
        流程（填写与流程条件相关的字段信息，将显示完整流程）
      </div>
      
      <div class="workflow">
        <node-renderer :mode="mode" :node="flowData.nodeConfig" />
      </div>
    </div>
  </div>
</template>
  
<script setup>
import { defineProps, provide} from 'vue';
import NodeRenderer from './NodeRenderer.vue';
  
const props = defineProps({
  flowData: {
    type: Object,
    required: false
  },
  processName: String,
  remark: String,
  mode: {
    type: String,
    default: 'preview'
  }
});
</script>
  
<style scoped>
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #eee;
}

.modal-title {
  font-size: 16px;
  font-weight: 500;
}

.close-btn {
  cursor: pointer;
  font-size: 20px;
  color: #999;
}

.modal-body {
  flex: 1;
  overflow-y: auto;
}

.form-group {
  margin-bottom: 20px;
}

.form-label {
  display: block;
  margin-bottom: 8px;
  font-size: 14px;
  color: #333;
}

.form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  background-color: #f5f5f5;
  font-size: 14px;
}

textarea.form-control {
  height: 100px;
  resize: none;
}

.char-count {
  text-align: right;
  font-size: 12px;
  color: #999;
  margin-top: 5px;
}

.process-info {
  font-size: 14px;
  color: #666;
  margin-bottom: 20px;
}

.workflow {
  margin-top: 20px;
}
</style>
