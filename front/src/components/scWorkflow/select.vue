<template>
	<el-dialog v-model="dialogVisible" :title="titleMap[type-1]" :width="type==1?680:460" destroy-on-close append-to-body @closed="$emit('closed')">

		<template v-if="type==1">
			<div class="sc-user-select">
				<div class="sc-user-select__left">
					<div class="sc-user-select__search">
						<el-input v-model="keyword" prefix-icon="el-icon-search" placeholder="搜索成员">
							<template #append>
								<el-button icon="el-icon-search" @click="search"></el-button>
							</template>
						</el-input>
					</div>
					<div class="sc-user-select__select">
						<div class="sc-user-select__tree" v-loading="showGrouploading">
							<el-scrollbar>
								<el-tree class="menu" ref="groupTree" :data="group" :node-key="groupProps.key" :props="groupProps" highlight-current :expand-on-click-node="false" :current-node-key="groupId" @node-click="groupClick"/>
							</el-scrollbar>
						</div>
						<div class="sc-user-select__user" v-loading="showUserloading">
							<div class="sc-user-select__user__list">
								<el-scrollbar ref="userScrollbar">
									<el-tree class="menu" ref="userTree" :data="user" :node-key="userProps.key" :props="userProps" :default-checked-keys="selectedIds" show-checkbox check-on-click-node @check-change="userClick"></el-tree>
								</el-scrollbar>
							</div>
							<footer>
								<el-pagination background layout="prev,next" small :total="total" :page-size="pageSize" v-model:currentPage="currentPage" @current-change="paginationChange"></el-pagination>
							</footer>
						</div>
					</div>
				</div>
				<div class="sc-user-select__toicon"><el-icon><el-icon-arrow-right /></el-icon></div>
				<div class="sc-user-select__selected">
					<header>已选 ({{selected.length}}) <span class="mode-hint">{{ mode === 1 ? '单选模式' : '多选模式' }}</span></header>
					<ul>
						<el-scrollbar>
							<li v-for="(item, index) in selected" :key="item.id">
								<span class="name">
									<el-avatar size="small">{{item.name.substring(0,1)}}</el-avatar>
									<label>{{item.name}}</label>
								</span>
								<span class="delete">
									<el-button type="danger" icon="el-icon-delete" circle size="small" @click="deleteSelected(index)"></el-button>
								</span>
							</li>
						</el-scrollbar>
					</ul>
				</div>
			</div>
		</template>

		<template v-if="type==2">
			<div class="sc-user-select sc-user-select-role">
				<div class="sc-user-select__left">
					<div class="sc-user-select__select">
						<div class="sc-user-select__tree" v-loading="showGrouploading">
							<el-scrollbar>
								<el-tree class="menu" ref="groupTree" :data="role" :node-key="roleProps.key" :props="roleProps" show-checkbox check-strictly check-on-click-node :expand-on-click-node="false" :default-checked-keys="selectedIds" @check-change="roleClick"/>
							</el-scrollbar>
						</div>
					</div>
				</div>
				<div class="sc-user-select__toicon"><el-icon><el-icon-arrow-right /></el-icon></div>
				<div class="sc-user-select__selected">
					<header>已选 ({{selected.length}})</header>
					<ul>
						<el-scrollbar>
							<li v-for="(item, index) in selected" :key="item.id">
								<span class="name">
									<el-avatar size="small">{{item.name.substring(0,1)}}</el-avatar>
									<label>{{item.name}}</label>
								</span>
								<span class="delete">
									<el-button type="danger" icon="el-icon-delete" circle size="small" @click="deleteSelected(index)"></el-button>
								</span>
							</li>
						</el-scrollbar>
					</ul>
				</div>
			</div>
		</template>


		<template #footer>
			<el-button @click="dialogVisible = false">取 消</el-button>
			<el-button type="primary" @click="save">确 认</el-button>
		</template>
	</el-dialog>
</template>

<script setup>
import { ref, computed, watch } from 'vue';
import config from '@/config/workflow.js';

// 定义props
const props = defineProps({
  modelValue: { type: Boolean, default: false }
});

// 定义emit
const emit = defineEmits(['update:modelValue', 'closed']);

// 数据
const dialogVisible = ref(false);
const showGrouploading = ref(false);
const showUserloading = ref(false);
const keyword = ref('');
const groupId = ref('');
const pageSize = ref(config.user.pageSize);
const total = ref(0);
const currentPage = ref(1);
const group = ref([]);
const user = ref([]);
const role = ref([]);
const type = ref(1);
const selected = ref([]);
const value = ref([]);
// 添加选择模式状态
const mode = ref(2); // 默认多选

// 计算属性
const selectedIds = computed(() => {
  return selected.value.map(t => t.id);
});

const titleMap = ['人员选择', '角色选择'];
const groupProps = config.group.props;
const userProps = config.user.props;
const roleProps = config.role.props;

// refs
const groupTree = ref(null);
const userTree = ref(null);
const userScrollbar = ref(null);

// 监听dialogVisible变化
watch(dialogVisible, (val) => {
  emit('update:modelValue', val);
});

// 监听modelValue变化
watch(() => props.modelValue, (val) => {
  dialogVisible.value = val;
});

// 打开选择器
const open = (selectType, data, selectMode = 2) => {
  type.value = selectType;
  value.value = data || [];
  selected.value = JSON.parse(JSON.stringify(data || []));
  // 保存选择模式 (1=单选, 2=多选)
  mode.value = selectMode;
  dialogVisible.value = true;

  if (type.value == 1) {
    getGroup();
    getUser();
  } else if (type.value == 2) {
    getRole();
  }
};

// 获取组织
const getGroup = async () => {
  showGrouploading.value = true;
  var res = await config.group.apiObj.get();
  showGrouploading.value = false;
  var allNode = {[config.group.props.key]: '', [config.group.props.label]: '所有'};
  res.data.unshift(allNode);
  group.value = config.group.parseData(res).rows;
};

// 获取用户
const getUser = async () => {
  showUserloading.value = true;
  var params = {
    [config.user.request.keyword]: keyword.value || null,
    [config.user.request.groupId]: groupId.value || null,
    [config.user.request.page]: currentPage.value,
    [config.user.request.pageSize]: pageSize.value
  };
  var res = await config.user.apiObj.get(params);
  showUserloading.value = false;
  user.value = config.user.parseData(res).rows;
  total.value = config.user.parseData(res).total || 0;
  userScrollbar.value.setScrollTop(0);
};

// 获取角色
const getRole = async () => {
  showGrouploading.value = true;
  var res = await config.role.apiObj.get();
  showGrouploading.value = false;
  role.value = config.role.parseData(res).rows;
};

// 组织点击
const groupClick = (data) => {
  keyword.value = '';
  currentPage.value = 1;
  groupId.value = data[config.group.props.key];
  getUser();
};

// 用户点击
const userClick = (data, checked) => {
  if (checked) {
    // 单选模式时，清空之前的选择
    if (mode.value === 1) {
      selected.value = [];
      // 如果是单选，需要重置其他节点的选中状态
      if (userTree.value) {
        userTree.value.setCheckedKeys([]);
      }
    }
    
    selected.value.push({
      id: data[config.user.props.key],
      name: data[config.user.props.label]
    });
    
    // 单选模式下，选中后即可设置选中状态
    if (mode.value === 1 && userTree.value) {
      userTree.value.setCheckedKeys([data[config.user.props.key]]);
    }
  } else {
    // 取消选中
    selected.value = selected.value.filter(item => item.id != data[config.user.props.key]);
  }
};

// 分页变化
const paginationChange = () => {
  getUser();
};

// 搜索
const search = () => {
  groupId.value = '';
  groupTree.value.setCurrentKey(groupId.value);
  currentPage.value = 1;
  getUser();
};

// 删除已选
const deleteSelected = (index) => {
  selected.value.splice(index, 1);
  if (type.value == 1) {
    userTree.value.setCheckedKeys(selectedIds.value);
  } else if (type.value == 2) {
    groupTree.value.setCheckedKeys(selectedIds.value);
  }
};

// 角色点击
const roleClick = (data, checked) => {
  if (checked) {
    selected.value.push({
      id: data[config.role.props.key],
      name: data[config.role.props.label]
    });
  } else {
    selected.value = selected.value.filter(item => item.id != data[config.role.props.key]);
  }
};

// 保存
const save = () => {
  value.value.splice(0, value.value.length);
  selected.value.forEach(item => {
    value.value.push(item);
  });
  dialogVisible.value = false;
};

// 暴露方法和属性给父组件
defineExpose({
  open,
  value
});
</script>

<style scoped>
	.sc-user-select {display: flex;}
	.sc-user-select__left {width: 400px;}
	.sc-user-select__right {flex: 1;}

	.sc-user-select__search {padding-bottom:10px;}

	.sc-user-select__select {display: flex;border: 1px solid var(--el-border-color-light);background: var(--el-color-white);}
	.sc-user-select__tree {width: 200px;height:300px;border-right: 1px solid var(--el-border-color-light);}
	.sc-user-select__user {width: 200px;height:300px;display: flex;flex-direction: column;}
	.sc-user-select__user__list {flex: 1;overflow: auto;}
	.sc-user-select__user footer {height:36px;padding-top:5px;border-top: 1px solid var(--el-border-color-light);}

	.sc-user-select__toicon {display: flex;justify-content: center;align-items: center;margin:0 10px;}
	.sc-user-select__toicon i {display: flex;justify-content: center;align-items: center;background: #ccc;width: 20px;height: 20px;text-align: center;line-height: 20px;border-radius:50%;color: #fff;}

	.sc-user-select__selected {height:345px;width: 200px;border: 1px solid var(--el-border-color-light);background: var(--el-color-white);}
	.sc-user-select__selected header {height:43px;line-height: 43px;border-bottom: 1px solid var(--el-border-color-light);padding:0 15px;font-size: 12px;}
	.mode-hint {
		font-size: 12px;
		color: #909399;
		background: #f4f4f5;
		padding: 2px 6px;
		border-radius: 4px;
		margin-left: 8px;
	}
	.sc-user-select__selected ul {height:300px;overflow: auto;}
	.sc-user-select__selected li {display: flex;align-items: center;justify-content: space-between;padding:5px 5px 5px 15px;height:38px;}
	.sc-user-select__selected li .name {display: flex;align-items: center;}
	.sc-user-select__selected li .name .el-avatar {background: #409eff;margin-right: 10px;}
	.sc-user-select__selected li .name label {}
	.sc-user-select__selected li .delete {display: none;}
	.sc-user-select__selected li:hover {background: var(--el-color-primary-light-9);}
	.sc-user-select__selected li:hover .delete {display: inline-block;}

	.sc-user-select-role .sc-user-select__left {width: 200px;}
	.sc-user-select-role .sc-user-select__tree {border: none;height: 343px;}
	.sc-user-select-role .sc-user-select__selected {}

	[data-theme='dark'] .sc-user-select__selected li:hover {background: rgba(0, 0, 0, 0.2);}
	[data-theme='dark'] .sc-user-select__toicon i {background: #383838;}
</style>
