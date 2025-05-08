<template>
  <div class="node-wrap">
    <div class="node-wrap-box start-node" @click="show">
      <div class="title" style="background: #909399;">
        <el-icon class="icon"><el-icon-user-filled /></el-icon>
        <span>{{ nodeConfig.nodeName }}</span>
      </div>
      <div class="content">
        <span>{{ toText(nodeConfig) }}</span>
      </div>
    </div>
    <add-node v-model="nodeConfig.childNode"></add-node>
    <el-drawer 
      title="发起人" 
      v-model="drawer" 
      destroy-on-close 
      append-to-body 
      :size="500"
      @closed="save"
    >
      <template #header>
        <div class="node-wrap-drawer__title">
          <label @click="editTitle" v-if="!isEditTitle">
            {{ form.nodeName }}
            <el-icon class="node-wrap-drawer__title-edit"><el-icon-edit /></el-icon>
          </label>
          <el-input 
            v-if="isEditTitle" 
            ref="nodeTitle" 
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
            <el-form-item label="谁可以发起此审批">
              <el-button type="primary" icon="el-icon-plus" round
                @click="selectHandle(2, form.nodeAssigneeList)">选择角色</el-button>
              <div class="tags-list">
                <el-tag 
                  v-for="(role, index) in form.nodeAssigneeList" 
                  :key="role.id" 
                  closable 
                  @close="delRole(index)"
                >
                  {{ role.name }}
                </el-tag>
              </div>
            </el-form-item>
            <el-alert 
              title="选择能发起该审批的人员，不选则默认开放给所有人" 
              type="info"
              :closable="false" 
            />
          </el-form>
        </el-main>
      </el-container>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, inject } from 'vue';
import AddNode from './addNode.vue';

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
const form = ref({
  nodeAssigneeList: []
});
const nodeTitle = ref(null);

watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal;
}, { immediate: true });

const show = () => {
  form.value = JSON.parse(JSON.stringify(nodeConfig.value));
  if (!form.value.nodeAssigneeList) {
    form.value.nodeAssigneeList = [];
  }
  isEditTitle.value = false;
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

const selectHandle = (type, data) => {
  select(type, data);
};

const delRole = (index) => {
  form.value.nodeAssigneeList.splice(index, 1);
};

const save = () => {
  emit('update:modelValue', form.value);
};

const toText = (nodeConfig) => {
  if (nodeConfig.nodeAssigneeList?.length > 0) {
    return nodeConfig.nodeAssigneeList.map(item => item.name).join("、");
  }
  return "所有人";
};
</script>

<style>
/* 保持原有样式 */
.node-wrap-drawer__title {
  display: flex;
  align-items: center;
}
.node-wrap-drawer__title-edit {
  margin-left: 8px;
  cursor: pointer;
}
.tags-list {
  margin-top: 10px;
}
.tags-list .el-tag {
  margin-right: 8px;
  margin-bottom: 8px;
}
</style>