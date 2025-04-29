<template>
    <div class="process-container">
      <!-- 左侧树形结构 -->
      <div class="left-tree">
        <el-tree 
          :data="treeData" 
          node-key="id" 
          default-expand-all 
          :props="treeProps"
          @node-click="handleNodeClick" 
        />
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
            <el-input 
              v-model="searchKeyword" 
              placeholder="搜索流程名称" 
              style="width: 200px; margin-right: 16px"
              @keyup.enter="handleSearch" 
            />
            <el-button 
              type="primary" 
              @click="handleCreate"
              :disabled="!selectedCategory"
            >新增流程</el-button>
          </div>
        </div>
  
        <!-- 表格区域 -->
        <div class="table-container">
          <el-table 
            :data="processList" 
            style="width: 100%"
            height="100%"
            v-loading="loading"
            border
          >
            <el-table-column label="序号" width="55" align="center">
              <template #default="{$index}">
                {{ (queryParams.current - 1) * queryParams.size + $index + 1 }}
              </template>
            </el-table-column>
            <el-table-column prop="processName" label="流程名称" min-width="120" align="center" />
            <!-- <el-table-column prop="processKey" label="流程标识" width="120" align="center" /> -->
            <el-table-column prop="processType" label="关联业务表" min-width="120" align="center" />
            <el-table-column prop="useScope" label="流程类型" min-width="120" align="center">
              <template #default="{ row }">
                <el-tag :type="row.useScope === 0 ? 'success' : 'warning'">{{ row.useScope === 0 ? '业务流程' : '子流程' }}</el-tag>
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
              <template #default="{row}">
                {{ formatDate(row.createTime) }}
              </template>
            </el-table-column>
  
            <el-table-column label="操作" width="260" fixed="right" align="center">
              <template #default="{ row }">
                <el-button size="small" @click="handleEdit(row)">编辑</el-button>
                <el-button size="small" type="danger" @click="handleDelete(row)">删除</el-button>
                <el-button size="small" type="primary" @click="handlePreview(row)">详情</el-button>
              </template>
            </el-table-column>
          </el-table>
  
          <div class="pagination-container">
            <el-pagination
              v-show="total > 0"
              :page-size="queryParams.size"
              layout="prev, pager, next"
              :total="total"
              :current-page="queryParams.current"
              @current-change="handlePagination"
              background
            />
          </div>
        </div>
      </div>
  
      <!-- 流程预览弹窗 -->
      <el-dialog v-model="previewVisible" title="查看详情" width="800px">
        <PreviewFlow 
          :flow-data="previewFlowData" 
          v-model:process-name="previewProcessName"
          v-model:remark="previewRemark" 
        />
      </el-dialog>
    </div>
</template>
  
<script setup>
import { ref, reactive, onMounted, watch } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { ElMessage, ElMessageBox } from 'element-plus';
import dayjs from 'dayjs';
import { getProcessList, deleteProcess } from '@/api/process';
import PreviewFlow from '@/components/PreviewFlow.vue';

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
const treeProps = {id: 'menudId', label: 'menudName' };

// 树形数据 - 实际项目中可能从API获取
const treeData = ref([
  { menudId: 2, menudName: '用户管理', path: '/user'},
  { menudId: 3, menudName: '采购管理', path: '/caigou'},
  { menudId: 4, menudName: '财务流程', path: '/caiwu'},
]);

// 状态映射
const stateMap = {
  0: { type: 'danger', text: '已禁用' },
  1: { type: 'success', text: '已启用' },
  2: { type: 'info', text: '历史版本' }
};

// 工具函数
const getStateType = (state) => stateMap[state]?.type || 'info';
const getStateText = (state) => stateMap[state]?.text || '未知状态';
const formatDate = (date) => dayjs(date).format('YYYY-MM-DD HH:mm');

// 初始化函数 - 处理路由返回时的状态恢复
const initFromRoute = async () => {
  const { processKey } = route.query;
  if (processKey) {
    const category = treeData.value.find(item => item.path === processKey);
      if (category) {
        await handleNodeClick(category);
    }
  }
};

// 获取流程列表数据
const fetchProcessList = async () => {
  if (!selectedCategory.value) return;
  
  try {
    loading.value = true;
    const res = await getProcessList({
      processKey: selectedCategory.value.path, 
      ...queryParams,
      keyword: searchKeyword.value
    });
    
    processList.value = res.data.records;
    total.value = res.data.total;
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
  if (!selectedCategory.value) {
    ElMessage.warning('请先在左侧选择流程分类');
    return;
  }
  
  router.push({
    name: 'ProcessCreate',
    query: { processKey: selectedCategory.value.path, module: selectedCategory.value.menudName }
  });
};

const handleEdit = (row) => {
  router.push({
    name: 'ProcessCreate',
    query: {
      editData: JSON.stringify(row)
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
  }).catch(() => {});
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
  () => initFromRoute(),
  { immediate: true }
);

// 组件挂载时初始化
onMounted(() => {
  initFromRoute();
});
</script>

<style scoped>
.process-container {
  display: flex;
  padding: 20px;
  gap: 16px;
  height: calc(100vh - 84px);
}

.left-tree {
  width: 240px;
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
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

.table-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  padding: 16px;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.pagination-container {
  position: sticky;
  bottom: 0;
  background: white;
  z-index: 2;
  padding: 12px 16px;
  border-top: 1px solid #ebeef5;
  display: flex;
  justify-content: flex-end;
  box-shadow: 0 -1px 4px rgba(0,0,0,0.05);
}

:deep(.el-table) {
  flex: 1;
  overflow: auto;
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
</style>
  