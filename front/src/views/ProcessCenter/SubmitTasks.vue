<template>
  <div class="tasks">
      <div class="table-wrapper">
          <el-table
              v-loading="loading"
              :data="tableData"
              style="width: 100%"
          >
              <el-table-column label="序号" width="55" align="center">
                  <template #default="{$index}">
                      {{ (queryParams.current - 1) * queryParams.size + $index + 1 }}
                  </template>
              </el-table-column>
              <el-table-column prop="processName" label="审批类型" align="center" />
              <el-table-column prop="startName" label="发起人" align="center" />
              <el-table-column prop="submitTime" label="提交时间" align="center">
                  <template #default="{row}">
                      {{ dayjs(row.submitTime).format('YYYY-MM-DD HH:mm') }}
                  </template>
              </el-table-column>
              <el-table-column prop="endTime" label="结束时间" align="center">
                  <template #default="{row}">
                      {{ row.endTime ? dayjs(row.endTime).format('YYYY-MM-DD HH:mm') : '-' }}
                  </template>
              </el-table-column>
              <el-table-column prop="currentNode" label="当前节点" align="center" />
              <el-table-column prop="taskState" label="审批状态" align="center">
                  <template #default="{row}">
                      <el-tag :type="getStateTagType(row.taskState)">
                          {{ row.taskState }}
                      </el-tag>
                  </template>
              </el-table-column>
              <el-table-column prop="duration" label="已耗时" align="center" />

              <el-table-column label="操作" align="left" width="120">
                  <template #default="{ row }">
                      <el-button 
                          size="small" 
                          type="primary" 
                          @click="handleDetail(row)"
                      >
                          详情
                      </el-button>
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
      <el-drawer       
      :title="drawer.title"
      v-model="drawer.visible" 
      size="40%"
      >
          <WorkFlowPro
              :businessKey="drawer.instanceId"
              :status="1"
              :readonly="true"
          />
      </el-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import { submitList } from '@/api/process';
import dayjs from 'dayjs';
import WorkFlowPro from '@/components/WorkFlowPro.vue'

// 外部接收一个isAll的参数
const props = defineProps({
  isAll: {
    type: Boolean,
    default: false
  }
})

// 状态标签类型映射
const stateTagMap = {
  '审批中': 'warning',
  '审批通过': 'success',
  '审批拒绝【 驳回结束流程 】': 'danger',
  '撤销审批': 'info',
  '超时结束': 'danger',
  '强制终止': 'danger',
  '自动通过': 'success',
  '自动拒绝': 'danger'
};

// 分页参数
const queryParams = reactive({
  current: 1,
  size: 10
});

// 抽屉相关
const drawer = reactive({
visible: false,
title: '',
instanceId: 0
})


const loading = ref(false);
const total = ref(0);
const tableData = ref([]);

const taskStateMap = {
  0: '审批中',
  1: '审批通过',
  2: '审批拒绝【 驳回结束流程 】',
  3: '撤销审批',
  4: '超时结束',
  5: '强制终止',
  6: '自动通过',
  7: '自动拒绝'
};

// 格式化处理耗时
const formatDuration = (duration) => {
  if (!duration) return '';

  // 如果是数字字符串，转换成 number 处理（假设是毫秒）
  if (typeof duration === 'string' && /^\d+$/.test(duration)) {
    duration = Number(duration);
  }

  // 如果是数字，假设是毫秒
  if (typeof duration === 'number') {
    const seconds = Math.floor(duration / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) {
      return `${hours}小时${minutes % 60}分钟`;
    } else if (minutes > 0) {
      return `${minutes}分钟${seconds % 60}秒`;
    } else {
      return `${seconds}秒`;
    }
}

// 如果已经是字符串格式
return duration;
};

// 获取状态标签类型
const getStateTagType = (state) => {
  return stateTagMap[state] || 'info';
};

// 打开详情弹窗
const handleDetail = (row) => {
  drawer.instanceId = row.instanceId
  drawer.title = `【${row.processName}】详情`
  drawer.visible = true
}

// 处理分页变化
const handlePagination = (current) => {
  queryParams.current = current;
  fetchData();
};

// 获取数据
const fetchData = async () => {
  try {
      loading.value = true;

      const listRes = await submitList(props.isAll, {...queryParams})
      
      tableData.value = listRes.data.records.map(item => ({
          ...item,
          taskState: taskStateMap[item.taskState] || '未知状态',
          duration: formatDuration(item.duration)
      }));
      
      total.value = listRes.data.total;
  } finally {
      loading.value = false;
  }
};

onMounted(fetchData);
</script>

<style scoped>
.tasks {
  padding: 20px;
}

.table-wrapper {
  position: relative;
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  height: calc(100vh - 160px); /* 根据实际布局调整 */
}

.el-table {
  flex: 1;
  overflow: auto;
}

.pagination-container {
  position: sticky;
  display: flex;
  justify-content: flex-end;
  bottom: 0;
  background: white;
  z-index: 2;
  padding: 12px 16px;
  border-top: 1px solid #ebeef5;
  box-shadow: 0 -1px 4px rgba(0,0,0,0.05);
  margin-top: auto;
}
</style>