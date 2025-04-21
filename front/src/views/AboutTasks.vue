<template>
    <div class="tasks">
        <el-table :data="tableData" style="width: 100%">
            <el-table-column prop="processName" label="审批类型" />
            <el-table-column prop="startName" label="发起人" />
            <el-table-column prop="submitTime" label="提交时间" />
            <el-table-column prop="endTime" label="结束时间" />
            <el-table-column prop="currentNode" label="当前节点" />
            <el-table-column prop="taskState" label="审批状态" />
            <el-table-column prop="duration" label="已耗时" />
        </el-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { aboutList } from '@/api/process';

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
    const res = await aboutList();
    if (res.code === 0) {
        tableData.value = res.data.records.map(item => ({
            ...item,
            taskState: taskStateMap[item.taskState],
            duration: formatDuration(item.duration)
        }));
    }
});
</script>

<style scoped>
.tasks {
    padding: 20px;
}
</style>