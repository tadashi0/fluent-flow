<template>
  <el-dialog
    v-model="props.visible"
    :title="dialogTitle"
    width="500px"
    :before-close="handleCancel"
    destroy-on-close
  >
    <div class="action-dialog-body">
      <!-- 意见输入，必填 -->
      <div class="form-item">
        <div class="label">
          <span class="required">*</span>意见
        </div>
        <el-input
          v-model="formData.comment"
          type="textarea"
          :rows="4"
          placeholder="请输入意见"
          maxlength="200"
          show-word-limit
        />
      </div>

      <!-- 抄送人选择，所有情况都显示 -->
      <div class="form-item">
        <div class="label">抄送人</div>
        <div class="select-input" @click="openUserSelector('ccUsers')">
          <div class="selected-tags" v-if="formData.ccUsers.length > 0">
            <el-tag
              v-for="user in selectedCCUserList"
              :key="user.id"
              closable
              @close="removeUser('ccUsers', user.id)"
            >
              {{ user.name }}
            </el-tag>
          </div>
          <div v-else class="placeholder-text">请选择抄送人</div>
          <div class="select-icon">
            <i class="el-icon-arrow-down"></i>
          </div>
        </div>
      </div>

      <!-- 转交人选择，仅转交操作时显示 -->
      <div v-if="actionType === 'transfer'" class="form-item">
        <div class="label">
          <span class="required">*</span>转交人
        </div>
        <div class="select-input" @click="openUserSelector('transferUser')">
          <div class="selected-tags" v-if="formData.transferUser">
            <el-tag
              closable
              @close="removeUser('transferUser')"
            >
              {{ formData.transferUser.name }}
            </el-tag>
          </div>
          <div v-else class="placeholder-text">请选择转交人</div>
          <div class="select-icon">
            <i class="el-icon-arrow-down"></i>
          </div>
        </div>
      </div>

      <!-- 回退节点选择，仅回退操作时显示 -->
      <div v-if="actionType === 'reclaim'" class="form-item">
        <div class="label">
          <span class="required">*</span>回退节点
        </div>
        <el-radio-group v-model="formData.reclaimNode">
          <el-radio
            v-for="node in reclaimNodes"
            :key="node.taskKey"
            :label="node.taskKey"
            border
            class="reclaim-node-item"
          >
            {{ node.taskName }}
            <span class="reclaim-node-user">{{ node.name }}</span>
          </el-radio>
        </el-radio-group>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="handleCancel">取消</el-button>
        <el-button type="primary" @click="handleConfirm" :disabled="!isFormValid">确定</el-button>
      </div>
    </template>
  </el-dialog>

  <!-- 集成用户角色选择器组件 -->
  <user-role-selector
    v-model="selectorVisible"
    ref="userRoleSelector"
    @closed="handleSelectorClosed"
  />
</template>

<script setup>
import { ref, computed, reactive, watch } from 'vue';
import { ElMessage } from 'element-plus';
import UserRoleSelector from './scWorkflow/select.vue';

const props = defineProps({
  businessKey: {
    type: String,
    required: true
  },
  actionType: {
    type: String,
    required: true,
    validator: (value) => ['approve', 'reject', 'transfer', 'reclaim', 'terminate'].includes(value)
  },
  visible: {
    type: Boolean,
    default: false
  },
  reclaimNodes: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits([
  'update:visible',
  'cancel',
  'confirm',
]);

// 表单数据
const formData = reactive({
  comment: '',         // 处理意见
  ccUsers: [],         // 抄送人
  transferUser: '',    // 转交人
  reclaimNode: ''      // 回退节点
});

// 用户选择器相关
const selectorVisible = ref(false);
const userRoleSelector = ref(null);
const currentSelectorField = ref('');

// 已选抄送人列表
const selectedCCUserList = computed(() => formData.ccUsers);

// 打开用户选择器
const openUserSelector = (field) => {
  currentSelectorField.value = field;
  
  if (userRoleSelector.value) {
    let currentSelectedItems = [];
    let selectMode = 2; // 默认多选
    
    if (field === 'ccUsers') {
      currentSelectedItems = formData.ccUsers;
    } else if (field === 'transferUser') {
      selectMode = 1;
      currentSelectedItems = formData.transferUser ? [formData.transferUser] : [];
    }
    
    userRoleSelector.value.open(1, currentSelectedItems, selectMode);
    selectorVisible.value = true;
  }
};

/// 处理选择器关闭后的回调
const handleSelectorClosed = () => {
  if (!userRoleSelector.value) return;
  
  const selectedItems = userRoleSelector.value.value || [];

  if (currentSelectorField.value === 'ccUsers') {
    formData.ccUsers = selectedItems; // 直接存储对象数组
  } else if (currentSelectorField.value === 'transferUser') {
    formData.transferUser = selectedItems.length > 0 ? selectedItems[0] : null;
  }
  
  currentSelectorField.value = '';
};

// 移除用户
const removeUser = (field, id) => {
  if (field === 'ccUsers' && id) {
    formData.ccUsers = formData.ccUsers.filter(user => user.id !== id);
  } else if (field === 'transferUser') {
    formData.transferUser = null;
  }
};

// 根据操作类型设置对话框标题
const dialogTitle = computed(() => {
  const titleMap = {
    approve: '同意',
    reject: '驳回',
    transfer: '转交',
    reclaim: '回退',
    terminate: '终止'
  };
  return `办理意见 - ${titleMap[props.actionType] || ''}`;
});

// 表单验证
const isFormValid = computed(() => {
  if (!formData.comment.trim()) return false;
  
  if (props.actionType === 'transfer' && !formData.transferUser?.id) {
    return false;
  }
  
  if (props.actionType === 'reclaim' && !formData.reclaimNode) {
    return false;
  }
  
  return true;
});

// 关闭对话框
const handleCancel = () => {
  emit('update:visible', false);
  emit('cancel');
};

// 确认操作
const handleConfirm = () => {
  if (!isFormValid.value) {
    ElMessage.warning('请填写必填项');
    return;
  }
  
  const result = {
    actionType: props.actionType,
    comment: formData.comment,
    // 转换为需要的格式（可根据实际需求调整）
    ccUsers: formData.ccUsers.map(u => ({ id: u.id, name: u.name })),
    businessKey: props.businessKey
  };
  
  if (props.actionType === 'transfer') {
    result.transferUser = formData.transferUser 
      ? { id: formData.transferUser.id, name: formData.transferUser.name }
      : null;
  }

  if (props.actionType === 'reclaim') {
    result.reclaimNode = props.reclaimNodes.find(node => node.taskKey === formData.reclaimNode)
  }
  
  // 触发确认事件，传递数据
  emit('confirm', result);
  // 关闭对话框
  emit('update:visible', false);
};

// 监听对话框可见性，重置表单
watch(() => props.visible, (newVal) => {
  if (newVal) {
    // 打开对话框时，重置表单
    formData.comment = '';
    formData.ccUsers = [];
    formData.transferUser = '';
    formData.reclaimNode = props.reclaimNodes?.[0]?.taskKey || {};
  }
});
</script>
  
<style scoped>
.action-dialog-body {
  padding: 10px 0;
}

.form-item {
  margin-bottom: 16px;
}

.label {
  font-size: 14px;
  margin-bottom: 8px;
  color: #606266;
}

.required {
  color: #f56c6c;
  margin-right: 4px;
}

.select-input {
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  padding: 5px 15px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.selected-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.user-tag {
  margin: 2px;
}

.placeholder-text {
  color: #c0c4cc;
}

.reclaim-node-item {
  display: block;
  width: 100%;
  margin: 8px 0;
  padding: 8px 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
}

.reclaim-node-user {
  color: #909399;
  font-size: 12px;
  margin-left: 8px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
}
</style>
  
  