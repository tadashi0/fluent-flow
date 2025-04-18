<template>
    <div class="dashboard">
        <el-row :gutter="20">
            <el-col :span="6" v-for="(item, index) in stats" :key="index">
                <el-card shadow="hover">
                    <div class="stat-card">
                        <div class="stat-title">{{ item.title }}</div>
                        <div class="stat-value">{{ item.value }}</div>
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { taskCount } from '@/api/process';

const stats = ref([
    { title: '待我处理数量', value: 0 },
    { title: '已处理的数量', value: 0 },
    { title: '我发起的数量', value: 0 },
    { title: '抄送我的数量', value: 0 }
]);

onMounted(async () => {
    const res = await taskCount();
    if (res.code === 0) {
        stats.value = [
            { title: '待我处理数量', value: res.data.todo },
            { title: '已处理的数量', value: res.data.done },
            { title: '我发起的数量', value: res.data.submit },
            { title: '抄送我的数量', value: res.data.about }
        ];
    }
});
</script>

<style scoped>
.dashboard {
    padding: 20px;
}

.stat-card {
    text-align: center;
}

.stat-title {
    font-size: 14px;
    color: #909399;
}

.stat-value {
    font-size: 24px;
    font-weight: bold;
    margin-top: 10px;
}
</style>