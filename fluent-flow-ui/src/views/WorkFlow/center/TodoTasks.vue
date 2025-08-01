<template>
    <div class="tasks">
        <ContentWrap>
            <el-table v-loading="loading" :data="tableData" stripe>
                <el-table-column label="序号" width="55" align="center">
                    <template #default="{ $index }">
                        {{ (queryParams.current - 1) * queryParams.size + $index + 1 }}
                    </template>
                </el-table-column>
                <el-table-column prop="title" label="标题" align="center" />
                <el-table-column prop="processName" label="审批类型" align="center" />
                <el-table-column prop="instanceId" label="流程实例编号" align="center" />
                <el-table-column prop="startName" label="发起人" align="center" />
                <el-table-column prop="submitTime" label="提交时间" align="center">
                    <template #default="{ row }">
                        {{ dayjs(row.submitTime).format('YYYY-MM-DD HH:mm:ss') }}
                    </template>
                </el-table-column>
                <el-table-column prop="currentNode" label="当前节点" align="center" />
                <el-table-column prop="taskState" label="状态" align="center">
                    <template #default="{ row }">
                        <el-tag :type="getStateTagType(row.taskState)">
                            {{ row.taskState }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="arriveTime" label="任务到达时间" align="center">
                    <template #default="{ row }">
                        {{ row.arriveTime ? dayjs(row.arriveTime).format('YYYY-MM-DD HH:mm:ss') : '-' }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" align="center" width="120">
                    <template #default="{ row }">
                        <el-button link type="primary" @click="handleDetail(row)">
                            详情
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
            <Pagination
                :total="total"
                v-model:page="queryParams.current"
                v-model:limit="queryParams.size"
                @pagination="fetchData"
            />
        </ContentWrap>

        <!-- 详情抽屉 -->
        <el-drawer :title="drawer.title" v-model="drawer.visible" size="40%">
            <WorkFlowPro :businessKey="drawer.instanceId" :status="1" :readonly="true" />
        </el-drawer>
    </div>
</template>

<script setup>
import { ref, onMounted, reactive } from 'vue';
import { todoList } from '@/api/workflow';
import dayjs from 'dayjs';
import { WorkFlowPro } from '@/components/WorkFlow';

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

const taskStateMap = {
    '-2': '已暂停',
    '-1': '待发起',
    0: '审批中',
    1: '审批通过',
    2: '审批拒绝【 驳回结束流程 】',
    3: '撤销审批',
    4: '超时结束',
    5: '强制终止',
    6: '自动通过',
    7: '自动拒绝'
};

// 获取状态标签类型
const getStateTagType = (state) => {
    return stateTagMap[state] || 'info';
};

// 打开详情抽屉
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
        const res = await todoList({
            current: queryParams.current,
            size: queryParams.size
        });

        if (res) {
            tableData.value = res.records.map(item => ({
                ...item,
                taskState: taskStateMap[item.taskState] || '未知状态',
            }));
            total.value = res.total;
        }
    } finally {
        loading.value = false;
    }
};

onMounted(fetchData);
</script>