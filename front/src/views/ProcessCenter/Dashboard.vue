<template>
    <div class="dashboard">
        <el-row :gutter="20">
            <el-col :span="6" v-for="(item, index) in statCards" :key="index">
                <el-card shadow="hover" class="stat-card" :body-style="{ padding: '20px' }">
                    <div class="card-content" :class="`type-${index}`">
                        <div class="stat-header">
                            <div class="icon-wrapper">
                                <component :is="cardIcons[index]" class="stat-icon" />
                            </div>
                            <div class="stat-title">{{ item.title }}</div>
                        </div>
                        <div class="stat-value">{{ item.value }}</div>
                        <div class="stat-subtext">最近更新</div>
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
    <SubmitTasks :isAll="true" />
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { todoCount, doneCount, submitCount, aboutCount } from '@/api/process';
import SubmitTasks from './SubmitTasks.vue'
import {
    Clock,
    Checked,
    DocumentAdd,
    Bell
} from '@element-plus/icons-vue'

const cardIcons = [Clock, Checked, DocumentAdd, Bell]

// 初始化统计卡片数据
const statCards = ref([
    { title: '待我处理', value: 0 },
    { title: '已处理', value: 0 },
    { title: '我发起的', value: 0 },
    { title: '抄送我', value: 0 }
]);

// 分别获取各个统计数据
const fetchData = () => {
    // 待处理数据
    todoCount().then(res => {
        statCards.value[0].value = res.data;
    });

    // 已处理数据
    doneCount().then(res => {
        statCards.value[1].value = res.data;
    });

    // 我发起的数据
    submitCount().then(res => {
        statCards.value[2].value = res.data;
    });

    // 抄送我的数据
    aboutCount().then(res => {
        statCards.value[3].value = res.data;
    });
};

onMounted(fetchData);
</script>

<style scoped lang="scss">
.dashboard {
    padding: 20px;
    padding-bottom: 0;
}

.stat-card {
    transition: transform 0.3s ease;

    &:hover {
        transform: translateY(-5px);
    }

    .card-content {
        position: relative;
        border-radius: 8px;
        padding: 20px;
        color: white;

        &::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border-radius: 8px;
            opacity: 0.1;
        }

        &.type-0 {
            background: linear-gradient(135deg, #ff6b6b, #ff8787);
        }

        &.type-1 {
            background: linear-gradient(135deg, #4cd964, #69f0ae);
        }

        &.type-2 {
            background: linear-gradient(135deg, #5b8cff, #82b1ff);
        }

        &.type-3 {
            background: linear-gradient(135deg, #ffa940, #ffcb6b);
        }

        .stat-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;

            .icon-wrapper {
                background: rgba(255, 255, 255, 0.2);
                border-radius: 50%;
                padding: 10px;
                margin-right: 15px;

                .stat-icon {
                    width: 24px;
                    height: 24px;
                }
            }

            .stat-title {
                font-size: 16px;
                font-weight: 500;
                letter-spacing: 0.5px;
            }
        }

        .stat-value {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
        }

        .stat-subtext {
            font-size: 12px;
            opacity: 0.9;
        }
    }
}

:deep(.el-card) {
    border: none;
    border-radius: 12px;

    .el-card__body {
        padding: 0 !important;
    }
}
</style>