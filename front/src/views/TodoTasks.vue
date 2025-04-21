<template>
    <div class="tasks">
        <el-table :data="tableData" style="width: 100%">
            <el-table-column prop="processName" label="审批类型" />
            <el-table-column prop="startName" label="发起人" />
            <el-table-column prop="submitTime" label="提交时间" />
            <el-table-column prop="currentNode" label="当前节点" />
            <el-table-column prop="arriveTime" label="任务到达时间" />
            <el-table-column prop="taskState" label="审批状态" />
        </el-table>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { todoList } from '@/api/process';

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

onMounted(async () => {
    const res = await todoList();
    if (res.code === 0) {
        tableData.value = res.data.records.map(item => ({
            ...item,
            taskState: taskStateMap[item.taskState]
        }));
    }
});
</script>

<style scoped>
.tasks {
    padding: 20px;
}
</style>