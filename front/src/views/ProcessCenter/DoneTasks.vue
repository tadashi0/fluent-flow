<template>
  <div class="tasks">
      <!-- 优化后的表格区域 -->
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
              <el-table-column prop="currentNode" label="任务节点名" align="center" />
              
              <!-- 时间列 -->
              <el-table-column prop="startTime" label="任务开始时间" align="center">
                  <template #default="{row}">
                      {{ row.startTime ? dayjs(row.startTime).format('YYYY-MM-DD HH:mm') : '-' }}
                  </template>
              </el-table-column>
              <el-table-column prop="finishTime" label="处理完成时间" align="center">
                  <template #default="{row}">
                      {{ row.finishTime ? dayjs(row.finishTime).format('YYYY-MM-DD HH:mm') : '-' }}
                  </template>
              </el-table-column>

              <el-table-column prop="duration" label="处理耗时" align="center">
                  <template #default="{row}">
                      {{ formatDuration(row.duration) }}
                  </template>
              </el-table-column>
              
              <!-- 状态列 -->
              <el-table-column prop="taskState" label="处理结果" align="center">
                  <template #default="{row}">
                      <el-tag :type="getStateTagType(row.taskState)">
                          {{ row.taskState }}
                      </el-tag>
                  </template>
              </el-table-column>

              <!-- 操作列 -->
              <el-table-column label="操作" align="center" width="120">
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

          <!-- 分页 -->
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

      <!-- 详情抽屉 -->
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
import { doneList } from '@/api/process';
import dayjs from 'dayjs';
import WorkFlowPro from '@/components/WorkFlowPro.vue';

// 分页参数
const queryParams = reactive({
  current: 1,
  size: 10
});

// 抽屉配置
const drawer = reactive({
visible: false,
title: '',
instanceId: 0
})

const loading = ref(false);
const total = ref(0);
const tableData = ref([]);

// 状态标签类型映射
const stateTagMap = {
  '审批中': 'warning',
  '跳转': 'info',
  '已通过': 'success',
  '已拒绝': 'danger',
  '已撤销': 'info',
  '已超时': 'danger',
  '已终止': 'danger',
  '驳回终止': 'danger',
  '自动完成': 'success',
  '自动驳回': 'danger',
  '自动跳转': 'info',
  '驳回跳转': 'warning',
  '驳回重审跳转': 'warning',
  '路由跳转': 'info'
};

const taskStateMap = {
  0: '审批中',
  1: '跳转',
  2: '已通过',
  3: '已拒绝',
  4: '已撤销',
  5: '已超时',
  6: '已终止',
  7: '驳回终止',
  8: '自动完成',
  9: '自动驳回',
  10: '自动跳转',
  11: '驳回跳转',
  12: '驳回重审跳转',
  13: '路由跳转'
};

// 格式化处理耗时
const formatDuration = (duration) => {
    if (!duration) return '-';

    // 如果是数字字符串，转换成 number 处理（假设是毫秒）
    if (typeof duration === 'string' && /^\d+$/.test(duration)) {
        duration = Number(duration);
    }

    if (typeof duration === 'number') {
    const seconds = Math.floor(duration / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    
    if (hours > 0) return `${hours}小时${minutes % 60}分`;
    if (minutes > 0) return `${minutes}分${seconds % 60}秒`;
    return `${seconds}秒`;
    }

    return duration;
};

// 获取状态标签类型
const getStateTagType = (state) => {
  return stateTagMap[state] || 'info';
};

// 打开详情抽屉
const handleDetail = (row) => {
  drawer.instanceId = row.instanceId
  drawer.title = `【${row.processName}】处理详情`
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
      const res = await doneList({
          current: queryParams.current,
          size: queryParams.size
      });
      
      if (res.code === 0) {
          tableData.value = res.data.records.map(item => ({
              ...item,
              taskState: taskStateMap[item.taskState] || '未知状态',
              duration: item.duration  // 已在模板中格式化
          }));
          total.value = res.data.total;
      }
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