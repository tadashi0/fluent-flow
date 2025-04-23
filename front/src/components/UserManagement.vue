<template>
    <div class="user-management">
        <div class="header">
            <el-input v-model="queryParams.keyword" placeholder="搜索用户" style="width: 300px; margin-right: 16px"
                @keyup.enter="searchUsers" />
            <el-button type="primary" @click="handleCreate">新增用户</el-button>
            <el-button type="danger" @click="handleBatchDelete">批量删除</el-button>
        </div>

        <el-table :data="userList" style="width: 100%; margin-top: 16px" @selection-change="handleSelectionChange">
            <el-table-column type="selection" width="55" />
            <el-table-column prop="id" label="ID" width="80" />
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="age" label="年龄" width="80" />
            <el-table-column prop="phoneNumber" label="手机号" width="150" />
            <el-table-column prop="status" label="状态" width="120">
                <template #default="{ row }">
                    <el-tag :type="statusTagType[row.status]">
                        {{ statusMap[row.status] }}
                    </el-tag>
                </template>
            </el-table-column>
            <el-table-column prop="gmt_created" label="创建时间" width="180" />
            <el-table-column prop="gmt_modified" label="修改时间" width="180" />
            <el-table-column label="操作" width="240">
                <template #default="{ row }">
                    <div>
                        <div v-if="row.status === 1">
                            <el-button size="small" type="primary" @click="handleEdit(row)">
                                审批
                            </el-button>
                            <el-button size="small" type="danger" @click="handleRevoke(row)">撤销</el-button>
                        </div>
                        <div v-else-if="![2,3].includes(row.status)">
                            <el-button size="small" @click="handleEdit(row)">
                                编辑
                            </el-button>
                            <el-button size="small" type="danger" @click="handleDelete(row)">
                                删除
                            </el-button>
                        </div>
                        <el-button size="small" type="primary" @click="handleDetail(row)">详情</el-button>
                    </div>
                </template>
            </el-table-column>
        </el-table>

        <el-dialog v-model="dialogVisible" :title="dialogTitle" width="30%">
            <el-form :model="formData" label-width="80px">
                <el-form-item label="姓名">
                    <el-input v-model="formData.name" />
                </el-form-item>
                <el-form-item label="年龄">
                    <el-input-number v-model="formData.age" :min="0" />
                </el-form-item>
                <el-form-item label="手机号">
                    <el-input v-model="formData.phoneNumber" />
                </el-form-item>
            </el-form>
            <WorkFlowPro
                :processKey="props.processKey"
                :businessKey="formData.id"
                :status="formData.status"
                :on-submit="handleSubmit"
                :on-save="handleSave"
                @cancel="dialogVisible = false"
                @refresh="loadFromLocalStorage"
            />
        </el-dialog>

        <el-drawer v-model="drawerVisible" :title="drawerTitle" size="50%">
            <el-descriptions :column="1" border>
                <el-descriptions-item label="姓名">{{ currentUser.name }}</el-descriptions-item>
                <el-descriptions-item label="年龄">{{ currentUser.age }}</el-descriptions-item>
                <el-descriptions-item label="手机号">{{ currentUser.phoneNumber }}</el-descriptions-item>
                <el-descriptions-item label="状态">
                    <el-tag :type="statusTagType[currentUser.status]">
                        {{ statusMap[currentUser.status] }}
                    </el-tag>
                </el-descriptions-item>
                <el-descriptions-item label="创建时间">{{ currentUser.gmt_created }}</el-descriptions-item>
                <el-descriptions-item label="修改时间">{{ currentUser.gmt_modified }}</el-descriptions-item>
            </el-descriptions>
            <WorkFlowPro
                :businessKey="formData.id"
                :status="currentUser.status"
                :readonly="true"
            />
        </el-drawer>
    </div>
</template>

<script setup>
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import StartFlow from '@/components/StartFlow.vue'
import ApproveFlow from '@/components/ApproveFlow.vue'
import WorkFlowPro from '@/components/WorkFlowPro.vue'
import { saveProcess, startProcess, revokeProcess, approveProcess, terminateProcess, rejectProcess, reclaimProcess} from '@/api/process'

const props = reactive({
    processKey: 'user',
    flowData: {}
})

const userList = ref([])

onMounted(() => {
    loadFromLocalStorage()
})

const queryParams = reactive({
    keyword: ''
})

const statusMap = {
    0: '待发起',
    1: '待审核',
    2: '审核通过',
    3: '审核不通过',
    4: '已驳回'
}

const statusTagType = {
    0: 'info',
    1: 'warning',
    2: 'success',
    3: 'danger',
    4: 'danger'
}

const statusOptions = computed(() => {
    return Object.entries(statusMap).map(([value, label]) => ({
        value: Number(value),
        label
    }))
})

const dialogVisible = ref(false)
const dialogTitle = ref('')
const drawerVisible = ref(false)
const drawerTitle = ref('用户详情')
const currentUser = ref({})
const formData = reactive({
    id: null,
    name: '',
    age: 0,
    phoneNumber: '',
    status: 0
})

const selectedUsers = ref([])

const searchUsers = () => {
    // 实现搜索逻辑
}

// 审批操作处理函数
const handleTransfer = async () => {
    // 实现转交逻辑
};
const handleReclaim = async () => {
    // await updateUserStatus(formData.id, 1) // 更新为审核不通过状态
    console.log("回退", formData.id)
};
const handleRevoke = async (row) => {
    // 实现撤销逻辑
    console.log("撤销", row)
    const index = userList.value.findIndex((item) => item.id === row.id)
    userList.value[index] = { ...row, status: 0 }
    saveToLocalStorage()
    const res = await revokeProcess(row.id)
    console.log("撤销结果", res)
    ElMessage.success('撤销成功')
};
const handleTerminate = async () => {
    await updateUserStatus(formData.id, 3) // 更新为审核不通过状态
}
const handleReject = async () => {
    await updateUserStatus(formData.id, 4) // 更新为已驳回状态
};

const handleApprove = async () => {
    await updateUserStatus(formData.id, 2) // 更新为审核通过状态
}

const updateUserStatus = (id, status) => {
  const index = userList.value.findIndex(item => item.id === id)
  userList.value[index].status = status
  userList.value[index].gmt_modified = new Date().toISOString()
  saveToLocalStorage()
}

const handleCreate = () => {
    Object.assign(formData, {
        id: null,
        name: '',
        age: 0,
        phoneNumber: '',
        status: 0
    })
    dialogTitle.value = '新增用户'
    dialogVisible.value = true
}

const handleDetail = (row) => {
    currentUser.value = row
    drawerVisible.value = true
    console.log("打开详情")
}

const handleEdit = (row) => {
    Object.assign(formData, row)
    dialogTitle.value = '编辑用户'
    dialogVisible.value = true
}

const handleDelete = async (row) => {
    try {
        await ElMessageBox.confirm('确认删除该用户?', '警告', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
        })
        userList.value = userList.value.filter((item) => item.id !== row.id)
        saveToLocalStorage()
        ElMessage.success('删除成功')
    } catch {
        // 取消操作
    }
}

const handleBatchDelete = async () => {
    if (!selectedUsers.value.length) {
        ElMessage.warning('请选择要删除的用户')
        return
    }
    try {
        await ElMessageBox.confirm('确认删除选中用户?', '警告', {
            confirmButtonText: '确认',
            cancelButtonText: '取消',
            type: 'warning'
        })
        const ids = selectedUsers.value.map((item) => item.id)
        userList.value = userList.value.filter((item) => !ids.includes(item.id))
        saveToLocalStorage()
        ElMessage.success('删除成功')
    } catch {
        // 取消操作
    }
}

const handleSelectionChange = (selection) => {
    selectedUsers.value = selection
}

const saveToLocalStorage = () => {
    localStorage.setItem('userManagementData', JSON.stringify(userList.value))
}

const loadFromLocalStorage = () => {
    console.log("加载数据")
    const data = localStorage.getItem('userManagementData')
    if (data) {
        userList.value = JSON.parse(data)
    }
}

const handleSave = async () => {
    if (formData.id) {
        // 编辑逻辑
        const index = userList.value.findIndex((item) => item.id === formData.id)
        userList.value[index] = { ...formData, status: 0}
    } else {
        // 新增逻辑
        formData.id = Date.now() // 假设 id 是当前时间戳，实际情况可能需要根据业务逻辑调整
        userList.value.push({
            ...formData,
            status: 0,
            gmt_created: new Date().toISOString(),
            gmt_modified: new Date().toISOString()
        })
    }
    saveToLocalStorage()
    return {id: formData.id}
}

const handleSubmit = async () => {
    if (formData.id) {
        // 编辑逻辑
        const index = userList.value.findIndex((item) => item.id === formData.id)
        userList.value[index] = { ...formData, status: 1 }
    } else {
        // 新增逻辑
        formData.id = Date.now()
        userList.value.push({
            ...formData,
            status: 1,
            gmt_created: new Date().toISOString(),
            gmt_modified: new Date().toISOString()
        })
    }
    saveToLocalStorage()
    return {id: formData.id}
}
</script>

<style scoped>
.user-management {
    padding: 20px;
}

.header {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
}

.dialog-footer {
    display: flex;
    justify-content: flex-end;
    flex-wrap: wrap;
    gap: 8px;
}
</style>