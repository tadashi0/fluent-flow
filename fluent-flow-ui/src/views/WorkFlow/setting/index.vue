<template>
  <div class="process-container" v-loading="pageLoading">
    <!-- 左侧树形结构 -->
    <div class="left-tree">
      <el-tree 
        :data="treeData" 
        node-key="id" 
        highlight-current
        :current-node-key="selectedCategory"
        :default-expanded-keys="defaultExpandedKeys"
        :props="treeProps"
        expand-on-click-node
        @node-click="handleNodeClick"
        v-loading="treeLoading"
      >
        <template #default="{ node, data }">
          <span 
            :class="{ 'disabled-node': !isLeafAndTypeTwo(data) }" 
          >
            {{ node.label }}
          </span>
        </template>
      </el-tree>
    </div>

    <!-- 右侧内容区域 -->
    <div class="right-content">
      <!-- 顶部操作栏 -->
      <div class="header">
        <el-radio-group v-model="selectedProcessType">
          <el-radio :label="true">有审批流程</el-radio>
          <el-radio :label="false">无审批流程</el-radio>
        </el-radio-group>

        <div class="right-actions">
          <el-input v-model="searchKeyword" placeholder="搜索流程名称" style="width: 200px; margin-right: 16px"
            @keyup.enter="handleSearch" />
          <el-button type="primary" @click="handleCreate" :disabled="!canCreateProcess">新增流程</el-button>
        </div>
      </div>

      <!-- 表格区域 -->
      <ContentWrap>
        <el-table :data="processList" v-loading="loading" stripe border>
          <el-table-column label="序号" width="55" align="center">
            <template #default="{ $index }">
              {{ (queryParams.current - 1) * queryParams.size + $index + 1 }}
            </template>
          </el-table-column>
          <el-table-column prop="processName" label="流程名称" min-width="120" align="center" />
          
          <!-- <el-table-column prop="processKey" label="流程标识" width="120" align="center" /> -->
          <el-table-column prop="processType" label="关联业务表" min-width="120" align="center" />
          <el-table-column prop="useScope" label="流程类型" min-width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="row.useScope === 0 ? 'success' : 'warning'">{{ row.useScope === 0 ? '业务流程' : '子流程'
              }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="processVersion" label="版本" width="100" align="center">
            <template #default="{ row }">
              <el-tag type="success">V{{ row.processVersion }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="processState" label="状态" width="120" align="center">
            <template #default="{ row }">
              <el-tag :type="getStateType(row.processState)">
                {{ getStateText(row.processState) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="createTime" label="创建时间" width="180" align="center">
            <template #default="{ row }">
              {{ formatDate(row.createTime) }}
            </template>
          </el-table-column>

          <el-table-column label="操作" width="260" fixed="right" align="center">
            <template #default="{ row }">
              <el-button link type="primary" @click="handleEdit(row)">编辑</el-button>
              <el-button link type="danger" @click="handleDelete(row)">删除</el-button>
              <el-button link type="primary" @click="handlePreview(row)">详情</el-button>
            </template>
          </el-table-column>
        </el-table>

        <Pagination
          v-model:page="queryParams.current"
          v-model:limit="queryParams.size"
          :total="total"
          @pagination="fetchProcessList"
        />
      </ContentWrap>
    </div>

    <!-- 流程预览弹窗 -->
    <el-dialog v-model="previewVisible" title="查看详情" width="800px">
      <PreviewFlow :flow-data="previewFlowData" v-model:process-name="previewProcessName"
        v-model:remark="previewRemark" />
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import dayjs from 'dayjs'
import { getProcessList, deleteProcess } from '@/api/workflow'
import { getMenuList } from '@/api/system/menu/index'
import { PreviewFlow } from '@/components/WorkFlow'

defineOptions({ name: 'FlowSetting' })

// 路由相关
const router = useRouter();
const route = useRoute();

// 分页参数
const queryParams = reactive({
  current: 1,
  size: 10
});

// 状态数据
const total = ref(0);
const loading = ref(false);
const treeLoading = ref(false);
const selectedProcessType = ref(false);
const searchKeyword = ref('');
const processList = ref([]);
const selectedCategory = ref(null);

// 预览相关
const previewVisible = ref(false);
const previewFlowData = ref({});
const previewProcessName = ref('');
const previewRemark = ref('');

// 树形数据配置
const treeProps = { id: 'id', label: 'name' };

// 树形数据
const treeData = ref([]);

// 默认展开的节点keys
const defaultExpandedKeys = ref([]);

// 计算属性：判断是否可以创建流程
const canCreateProcess = computed(() => {
  return selectedCategory.value && isLeafAndTypeTwo(selectedCategory.value);
});

// 状态映射
const stateMap = {
  0: { type: 'danger', text: '已禁用' },
  1: { type: 'success', text: '已启用' },
  2: { type: 'info', text: '历史版本' }
};

// 工具函数
const getStateType = (state) => stateMap[state]?.type || 'info';
const getStateText = (state) => stateMap[state]?.text || '未知状态';
const formatDate = (date) => dayjs(date).format('YYYY-MM-DD HH:mm:ss');

// 判断节点是否为叶子节点且type为2
const isLeafAndTypeTwo = (node) => {
  return node.type === 2 && (!node.children || node.children.length === 0);
};

// 计算默认展开的节点
const calculateDefaultExpandedKeys = (treeData) => {
  const expandedKeys = [];
  
  if (treeData.length > 0) {
    // 只展开第一个根节点，显示它的第一层子节点
    const firstRoot = treeData[0];
    expandedKeys.push(firstRoot.id);
  }
  
  return expandedKeys;
};

// 递归构建树形结构
const buildTree = (menuList) => {
  // 过滤掉type为3的节点
  const filteredList = menuList.filter(item => item.type !== 3);
  
  // 创建id到节点的映射
  const nodeMap = {};
  filteredList.forEach(item => {
    nodeMap[item.id] = {
      id: item.id,
      name: item.name,
      componentName: item.componentName,
      type: item.type,
      parentId: item.parentId,
      children: []
    };
  });

  // 构建树形结构
  const tree = [];
  filteredList.forEach(item => {
    const node = nodeMap[item.id];
    if (item.parentId && nodeMap[item.parentId]) {
      nodeMap[item.parentId].children.push(node);
    } else {
      tree.push(node);
    }
  });

  return tree;
};

// 获取菜单树形数据
const fetchMenuTree = async () => {
  try {
    treeLoading.value = true;
    const res = await getMenuList();
    treeData.value = buildTree(res);
    
    // 计算默认展开的节点
    defaultExpandedKeys.value = calculateDefaultExpandedKeys(treeData.value);
    
  } catch (error) {
    console.error('获取菜单数据失败:', error);
    ElMessage.error('获取菜单数据失败');
    treeData.value = [];
    defaultExpandedKeys.value = [];
  } finally {
    treeLoading.value = false;
  }
};

// 扁平化查找节点
const findNodeById = (tree, targetId) => {
  const stack = [...tree];
  while (stack.length) {
    const node = stack.pop();
    if (node.id === targetId) {
      return node;
    }
    if (node.children && node.children.length > 0) {
      stack.push(...node.children);
    }
  }
  return null;
};

// 通过componentName查找节点
const findNodeByPath = (tree, targetComponentName) => {
  const stack = [...tree];
  while (stack.length) {
    const node = stack.pop();
    if (node.componentName === targetComponentName) {
      return node;
    }
    if (node.children && node.children.length > 0) {
      stack.push(...node.children);
    }
  }
  return null;
};

// 初始化函数 - 处理路由返回时的状态恢复
const initFromRoute = async () => {
  const { processKey } = route.query;
  if (processKey && treeData.value.length > 0) {
    const category = findNodeByPath(treeData.value, processKey);
    if (category && isLeafAndTypeTwo(category)) {
      await handleNodeClick(category);
    }
  }
};

// 获取流程列表数据
const fetchProcessList = async () => {
  if (!selectedCategory.value || !isLeafAndTypeTwo(selectedCategory.value)) return;

  try {
    loading.value = true;
    const res = await getProcessList({
      processKey: selectedCategory.value.componentName,
      ...queryParams,
      keyword: searchKeyword.value
    });

    processList.value = res.records;
    total.value = res.total;
    selectedProcessType.value = processList.value.length > 0;
  } catch (error) {
    console.error('获取流程数据失败:', error);
    processList.value = [];
    total.value = 0;
  } finally {
    loading.value = false;
  }
};

// 事件处理函数
const handleNodeClick = async (category) => {
  // 只有叶子节点且type为2的才能被选中
  if (!isLeafAndTypeTwo(category)) {
    return;
  }

  selectedCategory.value = category;
  queryParams.current = 1;
  await fetchProcessList();
};

const handleSearch = () => {
  queryParams.current = 1;
  fetchProcessList();
};

const handlePagination = (current) => {
  queryParams.current = current;
  fetchProcessList();
};

const handleCreate = () => {
  if (!canCreateProcess.value) {
    ElMessage.warning('请先在左侧选择可用的流程分类');
    return;
  }

  router.push({
    name: 'FlowCreate',
    query: { processKey: selectedCategory.value.componentName, module: selectedCategory.value.name }
  });
};

const handleEdit = (row) => {
  router.push({
    name: 'FlowCreate',
    query: {
      id: row.id
    }
  });
};

const handleDelete = (row) => {
  ElMessageBox.confirm('确认删除该流程吗?', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(async () => {
    try {
      await deleteProcess({ processKey: row.processKey, processVersion: row.processVersion });
      await fetchProcessList(); // 重新加载数据以反映最新状态
      ElMessage.success('删除成功');
    } catch (error) {
      console.error('删除失败:', error);
      ElMessage.error('删除失败');
    }
  }).catch(() => { });
};

const handlePreview = (row) => {
  previewFlowData.value = JSON.parse(row.modelContent);
  previewProcessName.value = row.processName;
  previewRemark.value = row.remark;
  previewVisible.value = true;
};

// 监听路由变化，处理返回到此页面的情况
watch(
  () => route.query,
  () => {
    if (treeData.value.length > 0) {
      initFromRoute();
    }
  }
);

// 监听树数据变化，初始化路由状态
watch(
  () => treeData.value,
  () => {
    if (treeData.value.length > 0) {
      initFromRoute();
    }
  }
);

// 添加页面loading状态
const pageLoading = ref(false)

// 修改初始化方法
onMounted(async () => {
    pageLoading.value = true
    try {
        await fetchMenuTree()
    } finally {
        pageLoading.value = false
    }
})
</script>

<style scoped>
.process-container {
  display: flex;
  gap: 16px;
  height: calc(100vh - 84px);
}

.left-tree {
  width: 240px;
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  overflow-y: auto;
  max-height: 100%;
}

.right-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 16px;
  overflow: hidden;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

:deep(.el-table th.el-table__cell) {
  background-color: #f8f9fa;
}

:deep(.el-table .el-button) {
  margin: 2px;
}

.right-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.disabled-node {
  color: #C0C4CC;
  cursor: not-allowed;
}
</style>