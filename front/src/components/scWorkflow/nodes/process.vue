<template>
  <div class="node-wrap">
    <div class="node-wrap-box" @click="show">
      <div class="title" style="background: #9260FB;">
        <el-icon class="icon"><el-icon-money /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
        <el-icon class="close" @click.stop="delNode()"><el-icon-close /></el-icon>
      </div>
      <div class="content">
        <span v-if="toText(nodeConfig)">{{ toText(nodeConfig) }}</span>
        <span v-else class="placeholder">请选择子流程规则</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode"></add-node>
    <el-drawer title="子流程设置" v-model="drawer" destroy-on-close append-to-body :size="500" @closed="save">
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">{{form.nodeName}}<el-icon class="node-wrap-drawer__title-edit"><el-icon-edit /></el-icon></label>
          <el-input v-if="isEditTitle" ref="nodeTitle" v-model="form.nodeName" clearable @blur="saveTitle" @keyup.enter="saveTitle"></el-input>
        </div>
      </template>
      <el-container>
				<el-main style="padding:0 20px 20px 20px">
					<el-form label-position="top">
						<el-form-item label="选择要抄送的人员">
							<el-button type="primary" icon="el-icon-plus" round
								@click="selectHandle(1, form.nodeAssigneeList)">选择人员</el-button>
							<div class="tags-list">
								<el-tag v-for="(user, index) in form.nodeAssigneeList" :key="user.id" closable
									@close="delUser(index)">{{ user.name }}</el-tag>
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

const changeSetType = () => {
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
<style>
/* 保留原有样式 */
</style>