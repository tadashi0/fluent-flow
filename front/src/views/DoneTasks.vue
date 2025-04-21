<template>
    <div class="tasks">
        <el-table :data="tableData" style="width: 100%">
            <el-table-column prop="processName" label="审批类型" />
            <el-table-column prop="startName" label="发起人" />
            <el-table-column prop="currentNode" label="任务节点名" />
            <el-table-column prop="startTime" label="任务开始时间" />
            <el-table-column prop="finishTime" label="处理完成时间" />
            <el-table-column prop="duration" label="处理耗时" />
            <el-table-column prop="taskState" label="处理结果" />
        </el-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { doneList } from '@/api/process';

const tableData = ref([]);

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
  if (!duration) return '';
  
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

onMounted(async () => {
    const res = await doneList();
    if (res.code === 0) {
        tableData.value = res.data.records.map(item => ({
            ...item,
            taskState: taskStateMap[item.taskState],
            duration: formatDuration(item.duration) // 格式化处理耗时
        }));
    }
});
</script>

<style scoped>
.tasks {
    padding: 20px;
}
</style>