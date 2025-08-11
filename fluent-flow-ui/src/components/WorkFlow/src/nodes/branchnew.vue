<template>
  <div class="branch-wrap">
    <div class="branch-box-wrap">
      <div class="branch-box">
        <el-button
          class="add-branch"
          type="success"
          plain
          round
          @click="addTerm">
          添加条件
        </el-button>
        <div
          class="col-box"
          v-for="(item, index) in nodeConfig.conditionNodes"
          :key="index">
          <div class="condition-node">
            <div class="condition-node-box">
              <div
                class="auto-judge"
                @click="show(index)">
                <div
                  class="sort-left"
                  v-if="index != 0"
                  @click.stop="arrTransfer(index, -1)">
                  <el-icon><el-icon-arrow-left /></el-icon>
                </div>
                <div class="title">
                  <span class="node-title">{{ item.nodeName }}</span>
                  <span class="priority-title">优先级{{ item.priorityLevel }}</span>
                  <el-icon
                    class="close"
                    @click.stop="delTerm(index)">
                    <el-icon-close />
                  </el-icon>
                </div>
                <div class="content">
                  <span v-if="toText(nodeConfig, index)">{{ toText(nodeConfig, index) }}</span>
                  <span
                    v-else
                    class="placeholder">
                    请设置条件
                  </span>
                </div>
                <div
                  class="sort-right"
                  v-if="index != nodeConfig.conditionNodes.length - 1"
                  @click.stop="arrTransfer(index)">
                  <el-icon><el-icon-arrow-right /></el-icon>
                </div>
              </div>
              <add-node v-model="item.childNode"></add-node>
            </div>
          </div>
          <slot
            v-if="item.childNode"
            :node="item"></slot>
          <div
            class="top-left-cover-line"
            v-if="index == 0"></div>
          <div
            class="bottom-left-cover-line"
            v-if="index == 0"></div>
          <div
            class="top-right-cover-line"
            v-if="index == nodeConfig.conditionNodes.length - 1"></div>
          <div
            class="bottom-right-cover-line"
            v-if="index == nodeConfig.conditionNodes.length - 1"></div>
        </div>
      </div>
      <add-node v-model="nodeConfig.childNode"></add-node>
    </div>
    <el-drawer
      title="条件设置"
      v-model="drawer"
      destroy-on-close
      append-to-body
      :size="600"
      @closed="save">
      <template #header>
        <div class="node-wrap-drawer__title">
          <label
            @click="editTitle"
            v-if="!isEditTitle">
            {{ form.nodeName }}
            <el-icon class="node-wrap-drawer__title-edit"><el-icon-edit /></el-icon>
          </label>
          <el-input
            v-if="isEditTitle"
            ref="nodeTitle"
            v-model="form.nodeName"
            clearable
            @blur="saveTitle"
            @keyup.enter="saveTitle"></el-input>
        </div>
      </template>
          <div class="top-tips">满足以下条件时进入当前分支</div>
          <template v-for="(conditionGroup, conditionGroupIdx) in form.conditionList" :key="conditionGroupIdx">
            <div
              class="or-branch-link-tip"
              v-if="conditionGroupIdx != 0">
              或满足
            </div>
            <div class="condition-group-editor">
              <div class="header">
                <span>条件组 {{ conditionGroupIdx + 1 }}</span>
                <div @click="deleteConditionGroup(conditionGroupIdx)">
                  <el-icon class="branch-delete-icon"><el-icon-delete /></el-icon>
                </div>
              </div>

              <div class="main-content">
                <!-- 单个条件 -->
                <div class="condition-content-box cell-box">
                  <div>条件字段</div>
                  <div>运算符</div>
                  <div>值</div>
                </div>
                <div
                  class="condition-content"
                  v-for="(condition, idx) in conditionGroup"
                  :key="idx">
                  <div class="condition-relation">
                    <span>{{ idx == 0 ? '当' : '且' }}</span>
                    <div @click="deleteConditionList(conditionGroup, idx)">
                      <el-icon class="branch-delete-icon"><el-icon-delete /></el-icon>
                    </div>
                  </div>
                  <div class="condition-content">
                    <div class="condition-content-box">
                      <!-- 改为只能选择发起人 -->
                      <el-select
                        v-model="condition.field"
                        placeholder="条件字段">
                        <el-option label="发起人" value="initiator"></el-option>
                      </el-select>
                      <el-select
                        v-model="condition.operator"
                        placeholder="运算符">
                        <el-option
                          label="等于"
                          value="=="></el-option>
                        <el-option
                          label="不等于"
                          value="!="></el-option>
                        <el-option
                          label="包含"
                          value="include"></el-option>
                        <el-option
                          label="不包含"
                          value="notinclude"></el-option>
                      </el-select>
                      <!-- 改为使用人员选择组件 -->
                      <div class="user-selector">
                        <el-button 
                          type="primary" 
                          icon="el-icon-plus" 
                          round 
                          @click="selectHandle(1, condition)">
                          选择人员
                        </el-button>
                        <div class="tags-list" v-if="condition.nodeAssigneeList && condition.nodeAssigneeList.length > 0">
                          <el-tag 
                            v-for="(user, userIdx) in condition.nodeAssigneeList" 
                            :key="user.id" 
                            closable 
                            @close="delUser(condition, userIdx)">
                            {{user.name}}
                          </el-tag>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="sub-content">
                <el-button
                  link
                  type="primary"
                  @click="addConditionList(conditionGroup)"
                  icon="el-icon-plus">
                  添加条件
                </el-button>
              </div>
            </div>
          </template>
          <el-button
            style="width: 100%"
            type="info"
            icon="el-icon-plus"
            text
            bg
            @click="addConditionGroup">
            添加条件组
          </el-button>
        <el-footer>
          <el-button
            type="primary"
            @click="save">
            保存
          </el-button>
          <el-button @click="drawer = false">取消</el-button>
        </el-footer>
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, watch, nextTick, inject } from 'vue';
import addNode from './addNode.vue';

const props = defineProps({
  modelValue: { 
    type: Object, 
    default: () => ({}) 
  }
});

const emit = defineEmits(['update:modelValue']);

// 注入选择人员的方法
const select = inject('select');

const nodeConfig = ref({});
const drawer = ref(false);
const isEditTitle = ref(false);
const index = ref(0);
const form = ref({});
const nodeTitle = ref(null);

watch(() => props.modelValue, () => {
  nodeConfig.value = props.modelValue;
}, { immediate: true });

const show = (idx) => {
  index.value = idx;
  form.value = JSON.parse(JSON.stringify(nodeConfig.value.conditionNodes[idx]));
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
  if (nodeConfig.value.conditionNodes) {
    nodeConfig.value.conditionNodes[index.value] = form.value;
    emit('update:modelValue', nodeConfig.value);
  }
  drawer.value = false;
};

const addTerm = () => {
  if (!nodeConfig.value.conditionNodes) {
    nodeConfig.value.conditionNodes = [];
  }
  
  let len = nodeConfig.value.conditionNodes.length + 1;
  nodeConfig.value.conditionNodes.push({
    nodeName: '条件' + len,
    type: 3,
    priorityLevel: len,
    conditionMode: 1,
    conditionList: []
  });
  
  emit('update:modelValue', nodeConfig.value);
};

const delTerm = (idx) => {
  nodeConfig.value.conditionNodes.splice(idx, 1);
  
  if (nodeConfig.value.conditionNodes.length == 1) {
    if (nodeConfig.value.childNode) {
      if (nodeConfig.value.conditionNodes[0].childNode) {
        reData(nodeConfig.value.conditionNodes[0].childNode, nodeConfig.value.childNode);
      } else {
        nodeConfig.value.conditionNodes[0].childNode = nodeConfig.value.childNode;
      }
    }
    emit('update:modelValue', nodeConfig.value.conditionNodes[0].childNode);
  } else {
    emit('update:modelValue', nodeConfig.value);
  }
};

const reData = (data, addData) => {
  if (!data.childNode) {
    data.childNode = addData;
  } else {
    reData(data.childNode, addData);
  }
};

const arrTransfer = (idx, type = 1) => {
  nodeConfig.value.conditionNodes[idx] = nodeConfig.value.conditionNodes.splice(idx + type, 1, nodeConfig.value.conditionNodes[idx])[0];
  nodeConfig.value.conditionNodes.forEach((item, i) => {
    item.priorityLevel = i + 1;
  });
  emit('update:modelValue', nodeConfig.value);
};

const addConditionList = (conditionGroup) => {
  conditionGroup.push({
    field: 'initiator',
    operator: '==',
    nodeAssigneeList: []
  });
};

const deleteConditionList = (conditionGroup, idx) => {
  conditionGroup.splice(idx, 1);
};

const addConditionGroup = () => {
  if (!form.value.conditionList) {
    form.value.conditionList = [];
  }
  
  const newGroup = [];
  addConditionList(newGroup);
  form.value.conditionList.push(newGroup);
};

const deleteConditionGroup = (idx) => {
  form.value.conditionList.splice(idx, 1);
};

// 处理选择人员
const selectHandle = (type, condition) => {
  // 初始化用户列表
  if (!condition.nodeAssigneeList) {
    condition.nodeAssigneeList = [];
  }
  
  // 调用注入的选择方法，传入回调函数处理选择结果
  select(type, condition.nodeAssigneeList, (selectedUsers) => {
    // 更新条件的值为用户ID字符串，方便条件判断
    condition.value = selectedUsers.map(user => user.id).join(',');
  });
};

// 删除已选用户
const delUser = (condition, idx) => {
  condition.nodeAssigneeList.splice(idx, 1);
  // 更新条件的值
  condition.value = condition.nodeAssigneeList.map(user => user.id).join(',');
};

// 转换条件为文本显示
const toText = (nodeConfig, idx) => {
  const { conditionList } = nodeConfig.conditionNodes[idx];
  
  if (conditionList && conditionList.length == 1) {
    const text = conditionList.map((conditionGroup) => {
      return conditionGroup.map((item) => {
        // 获取操作符的文本表示
        let operatorText = '';
        switch(item.operator) {
          case '==': operatorText = '等于'; break;
          case '!=': operatorText = '不等于'; break;
          case 'include': operatorText = '包含'; break;
          case 'notinclude': operatorText = '不包含'; break;
          default: operatorText = item.operator;
        }
        
        // 获取用户名称列表
        let userNames = '未选择';
        if (item.nodeAssigneeList && item.nodeAssigneeList.length > 0) {
          userNames = item.nodeAssigneeList.map(u => u.name).join('、');
        }
        
        return `发起人 ${operatorText} ${userNames}`;
      }).join(' 且 ');
    }).join(' 或 ');
    
    return text;
  } else if (conditionList && conditionList.length > 1) {
    return conditionList.length + '个条件，或满足';
  } else {
    if (idx == nodeConfig?.value?.conditionNodes?.length - 1) {
      return '其他条件进入此流程';
    } else {
      return false;
    }
  }
};
</script>

<style scoped lang="scss">
.top-tips {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
  color: #646a73;
}

.or-branch-link-tip {
  margin: 10px 0;
  color: #646a73;
}

.condition-group-editor {
  user-select: none;
  border-radius: 4px;
  border: 1px solid #e4e5e7;
  position: relative;
  margin-bottom: 16px;

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
      display: flex;
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
      
      .user-selector {
        display: flex;
        flex-direction: column;
        
        .tags-list {
          margin-top: 8px;
          display: flex;
          flex-wrap: wrap;
          gap: 4px;
        }
        
        .placeholder {
          color: #909399;
          font-size: 14px;
          margin-top: 8px;
        }
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

      :deep(.el-input__wrapper) {
        border-top-left-radius: 0;
        border-bottom-left-radius: 0;
      }

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

.branch-wrap {
  position: relative;
  
  .branch-box-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  
  .node-wrap-drawer__title {
    display: flex;
    align-items: center;
    
    .node-wrap-drawer__title-edit {
      margin-left: 8px;
      font-size: 16px;
      cursor: pointer;
      color: #409eff;
    }
  }
}
</style>
