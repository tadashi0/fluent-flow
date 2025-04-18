<template>
    <div class="process-container">
        <div class="left-tree">
            <el-tree :data="treeData" node-key="id" default-expand-all :props="treeProps"
                @node-click="handleNodeClick" />
        </div>

        <div class="right-content">
            <div class="header">
                <el-radio-group v-model="selectedProcessType">
                    <el-radio :label="true">有审批流程</el-radio>
                    <el-radio :label="false">无审批流程</el-radio>
                </el-radio-group>

                <div class="right-actions">
                    <el-input v-model="searchKeyword" placeholder="搜索流程名称" style="width: 200px; margin-right: 16px"
                        @keyup.enter="handleSearch" />
                    <el-button type="primary" @click="handleCreate">新增流程</el-button>
                </div>
            </div>

            <div class="table-container">
                <el-table :data="processList" border style="width: 100%" height="100%">
                    <el-table-column prop="processName" label="流程名称" min-width="100" />
                    <el-table-column prop="processKey" label="流程标识" width="120" />
                    <!-- <el-table-column prop="processVersion" label="版本" width="80" /> -->
                    <!-- // 版本使用tag展示 -->
                    <el-table-column prop="processVersion" label="版本" width="80">
                        <template #default="{ row }">
                            <el-tag type="success">
                                V{{ row.processVersion }}
                            </el-tag>
                        </template>
                    </el-table-column>
                    <el-table-column prop="processState" label="状态" width="100">
                        <template #default="{ row }">
                            <el-tag :type="row.processState ? 'success' : 'danger'">
                                {{ row.processState ? '启用' : '禁用' }}
                            </el-tag>
                        </template>
                    </el-table-column>
                    <el-table-column prop="createTime" label="创建时间" width="180" />

                    <el-table-column label="操作" width="260" fixed="right">
                        <template #default="{ row }">
                            <el-button size="small" @click="handleEdit(row)">编辑</el-button>
                            <el-button size="small" @click="handleCopy(row)">复制</el-button>
                            <el-button size="small" type="danger" @click="handleDisable(row)" v-if="row.processState">
                                禁用
                            </el-button>
                            <el-button size="small" type="danger" @click="handleDelete(row)">
                                删除
                            </el-button>
                            <el-button size="small" @click="handlePreview(row)">详情</el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </div>
        </div>
        <el-dialog v-model="previewVisible" title="查看详情" width="800px">
            <PreviewFlow :flow-data="previewFlowData" v-model:process-name="previewProcessName"
                v-model:remark="previewRemark" />
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getProcessList, disableProcess, deleteProcess } from '@/api/process'
import PreviewFlow from '@/components/PreviewFlow.vue'

const route = useRoute()
// 临时模拟数据
const treeData = ref([
    {
        id: 1,
        label: '全部流程',
        children: [
            { id: 2, label: '用户管理', componentName: 'user' },
            { id: 3, label: '采购管理', componentName: 'purchase' },
            { id: 4, label: '财务流程', componentName: 'finance' }
        ]
    }
])

const selectedProcessType = ref(false)
const searchKeyword = ref('')

const processList = ref([])

const treeProps = {
    children: 'children',
    label: 'label'
}

const handleSearch = () => {
    // 执行搜索逻辑
}

const router = useRouter()

const selectedComponent = ref(null)

const handleCreate = () => {
    if (!selectedComponent.value) {
        ElMessage.warning('请先在左侧选择流程分类')
        return
    }
    router.push({
        name: 'ProcessCreate',
        query: {
            componentName: selectedComponent.value.componentName
        }
    })
}

const handleNodeClick = async (data) => {
    console.log('点击树节点:', data)
    selectedComponent.value = data

    try {
        const res = await getProcessList(data.componentName)
        processList.value = res.data
        selectedProcessType.value = processList.value.length > 0
    } catch (error) {
        console.error('获取流程数据失败:', error)
        processList.value = []
        ElMessage.error('获取流程数据失败')
    }
}

const handleEdit = (row) => {
    router.push({
        name: 'ProcessCreate',
        query: {
            componentName: selectedComponent.value.componentName,
            editData: JSON.stringify(row)
        }
    })
}

const handleCopy = (row) => {
    console.log('复制', row)
}

const handleDisable = async (row) => {
    try {
        await disableProcess(row.id)
        row.processState = false
        ElMessage.success('禁用成功')
    } catch (error) {
        console.error('禁用失败:', error)
        ElMessage.error('禁用失败')
    }
}

const previewVisible = ref(false)
const previewFlowData = ref({})
const previewProcessName = ref('')
const previewRemark = ref('')

const handlePreview = (row) => {
    previewFlowData.value = JSON.parse(row.modelContent)
    previewProcessName.value = row.processName
    previewRemark.value = row.remark
    previewVisible.value = true
}

const handleDelete = (row) => {
    ElMessageBox.confirm('确认删除该流程吗?', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
    }).then(async () => {
        try {
            await deleteProcess(row.id)
            const index = processList.value.findIndex(item => item.id === row.id)
            if (index !== -1) {
                processList.value.splice(index, 1)
            }
            ElMessage.success('删除成功')
        } catch (error) {
            console.error('删除失败:', error)
            ElMessage.error('删除失败')
        }
    }).catch(() => {
        ElMessage.info('已取消删除')
    })
}
</script>

<style scoped>
.process-container {
    display: flex;
    padding: 16px;
    gap: 16px;
}

.left-tree {
    width: 240px;
    background: #fff;
    padding: 16px;
    border-radius: 4px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, .1);
}

.right-content {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 16px;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: #fff;
    border-radius: 4px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, .1);
}

.table-container {
    flex: 1;
    background: #fff;
    padding: 16px;
    border-radius: 4px;
    box-shadow: 0 2px 12px 0 rgba(0, 0, 0, .1);
    overflow: hidden;
}
</style>