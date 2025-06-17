<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #ff943e;">
        <el-icon class="icon"><el-icon-user-filled /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode()"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span v-if="toText(nodeConfig)">{{ toText(nodeConfig) }}</span>
        <span v-else class="placeholder">请选择</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode"></add-node>
    <el-drawer title="审批人设置" v-model="drawer" destroy-on-close append-to-body :size="600" @closed="save">
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">{{form.nodeName}}<el-icon class="node-wrap-drawer__title-edit"><el-icon-edit /></el-icon></label>
          <el-input v-if="isEditTitle" ref="nodeTitle" v-model="form.nodeName" clearable @blur="saveTitle" @keyup.enter="saveTitle"></el-input>
        </div>
      </template>
      <el-container>
        <el-main style="padding:0 20px 20px 20px">
          <el-form label-position="top">

            <el-form-item label="审批人员类型">
              <div class="approver-type-grid">
                <div 
                  v-for="option in approverTypeOptions" 
                  :key="option.value"
                  @click="selectApproverType(option.value)"
                >
                  <el-radio :label="option.value" v-model="form.setType">{{ option.label }}</el-radio>
                </div>
              </div>
            </el-form-item>

            <el-form-item v-if="form.setType==1" label="选择成员">
              <el-button type="primary" icon="el-icon-plus" round @click="selectHandle(1, form.nodeAssigneeList)">选择人员</el-button>
              <div class="tags-list">
                <el-tag v-for="(user, index) in form.nodeAssigneeList" :key="user.id" closable @close="delUser(index)">{{user.name}}</el-tag>
              </div>
            </el-form-item>

            <el-form-item v-if="form.setType==2" label="指定主管">
              发起人的第  <el-input-number v-model="form.examineLevel" :min="1"/>  级主管
            </el-form-item>

            <el-form-item v-if="form.setType==3" label="选择角色">
              <el-button type="primary" icon="el-icon-plus" round @click="selectHandle(2, form.nodeAssigneeList)">选择角色</el-button>
              <div class="tags-list">
                <el-tag v-for="(role, index) in form.nodeAssigneeList" :key="role.id" type="info" closable @close="delRole(index)">{{role.name}}</el-tag>
              </div>
            </el-form-item>

            <el-form-item v-if="form.setType==4" label="发起人自选">
              <el-radio-group v-model="form.selectMode">
                <el-radio :label="1">自选一个人</el-radio>
                <el-radio :label="2">自选多个人</el-radio>
              </el-radio-group>
            </el-form-item>

            <el-form-item v-if="form.setType==6" label="连续主管审批终点">
              <el-radio-group v-model="form.directorMode">
                <el-radio :label="0">直到最上层主管</el-radio>
                <el-radio :label="1">自定义审批终点</el-radio>
              </el-radio-group>
              <p v-if="form.directorMode==1">直到发起人的第  <el-input-number v-model="form.directorLevel" :min="1"/> 级主管</p>
            </el-form-item>

            <el-divider></el-divider>
            <el-form-item label="">
              <el-checkbox v-model="form.termAuto" label="超时自动审批"></el-checkbox>
              <el-checkbox v-model="form.remind" label="审批提醒"></el-checkbox>
            </el-form-item>
            <template v-if="form.termAuto">
              <el-form-item label="审批期限（为 0 则不生效）">
                <el-input-number v-model="form.term" :min="0"/> 小时
              </el-form-item>
              <el-form-item label="审批期限超时后执行">
                <el-radio-group v-model="form.termMode">
                  <el-radio :label="0">自动通过</el-radio>
                  <el-radio :label="1">自动拒绝</el-radio>
                </el-radio-group>
              </el-form-item>
            </template>
            <el-divider></el-divider>
            
            <!-- 只有在多人审批的情况下才显示审批方式 -->
            <el-form-item v-if="isMultipleApprovers" label="多人审批时审批方式">
              <el-radio-group v-model="form.examineMode">
                <p style="width: 100%;"><el-radio :label="1">按顺序依次审批</el-radio></p>
                <p style="width: 100%;"><el-radio :label="2">会签 (可同时审批，每个人必须审批通过)</el-radio></p>
                <p style="width: 100%;"><el-radio :label="3">或签 (有一人审批通过即可)</el-radio></p>
              </el-radio-group>
            </el-form-item>

            <el-form-item label="审批人与提交人为同一人时">
              <el-radio-group v-model="form.approveSelf">
                <p style="width: 100%;"><el-radio :label="0">由发起人对自己审批</el-radio></p>
                <p style="width: 100%;"><el-radio :label="1">自动跳过</el-radio></p>
                <p style="width: 100%;"><el-radio :label="2">转交给直接上级审批</el-radio></p>
                <p style="width: 100%;"><el-radio :label="3">转交给部门负责人审批</el-radio></p>
              </el-radio-group>
            </el-form-item>
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, inject, computed } from 'vue';
import addNode from './addNode.vue';

const props = defineProps({
  modelValue: { 
    type: Object, 
    default: () => ({}) 
  }
});

const emit = defineEmits(['update:modelValue']);

const select = inject('select');
const nodeConfig = ref({});
const drawer = ref(false);
const isEditTitle = ref(false);
const form = ref({});
const nodeTitle = ref(null);

// 审批人员类型选项
const approverTypeOptions = ref([
  { value: 1, label: '指定成员' },
  { value: 2, label: '主管' },
  { value: 3, label: '角色' },
  { value: 4, label: '发起人自选' },
  { value: 5, label: '发起人自己' },
  { value: 6, label: '连续多级主管' }
]);

// 计算属性：判断是否为多人审批
const isMultipleApprovers = computed(() => {
  // 判断条件：
  // 1. 指定成员且有多个成员
  if (form.value.setType === 1 && form.value.nodeAssigneeList?.length > 1) {
    return true;
  }
  // 2. 角色（通常角色包含多人）
  if (form.value.setType === 3) {
    return true;
  }
  // 3. 发起人自选多人
  if (form.value.setType === 4 && form.value.selectMode === 2) {
    return true;
  }
  // 4. 连续多级主管
  if (form.value.setType === 6) {
    return true;
  }
  
  return false;
});

watch(() => props.modelValue, () => {
  nodeConfig.value = props.modelValue;
}, { immediate: true });

const show = () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value));
  drawer.value = true;
};

const editTitle = () => {
  isEditTitle.value = true;
  nextTick(() => {
    nodeTitle.value.focus();
  });
};

const saveTitle = () => {
  isEditTitle.value = false;
};

const save = () => {
  emit('update:modelValue', form.value);
};

const delNode = () => {
  emit('update:modelValue', nodeConfig.value.childNode);
};

const delUser = (index) => {
  form.value.nodeAssigneeList.splice(index, 1);
};

const delRole = (index) => {
  form.value.nodeAssigneeList.splice(index, 1);
};

const selectHandle = (type, data) => {
  select(type, data);
};

const selectApproverType = (value) => {
  form.value.setType = value;
  form.value.nodeAssigneeList = [];
};

const toText = (nodeConfig) => {
  if (nodeConfig.setType == 1) {
    if (nodeConfig.nodeAssigneeList && nodeConfig.nodeAssigneeList.length > 0) {
      const users = nodeConfig.nodeAssigneeList.map(item => item.name).join("、");
      return users;
    } else {
      return false;
    }
  } else if (nodeConfig.setType == 2) {
    return nodeConfig.examineLevel == 1 ? '直接主管' : `发起人的第${nodeConfig.examineLevel}级主管`;
  } else if (nodeConfig.setType == 3) {
    if (nodeConfig.nodeAssigneeList && nodeConfig.nodeAssigneeList.length > 0) {
      const roles = nodeConfig.nodeAssigneeList.map(item => item.name).join("、");
      return '角色-' + roles;
    } else {
      return false;
    }
  } else if (nodeConfig.setType == 4) {
    return "发起人自选";
  } else if (nodeConfig.setType == 5) {
    return "发起人自己";
  } else if (nodeConfig.setType == 6) {
    return "连续多级主管";
  }
};
</script>

<style scoped>
/* 审批人员类型网格布局 */
.approver-type-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px; 
}
</style>