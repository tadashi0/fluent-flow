<template>
  <div class="app-container">
    <ContentWrap>
      <!-- 搜索区域 -->
      <el-form :inline="true" class="search-form">
        <el-form-item label="姓名">
          <el-input v-model="queryParams.name" placeholder="请输入姓名" clearable />
        </el-form-item>
        <el-form-item label="审批状态">
          <el-select v-model="queryParams.state" placeholder="请选择状态" clearable :style="'width: 120px'">
            <el-option v-for="item in stateOptions" :key="item.value" :label="item.label" :value="item.value" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">搜索</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 操作按钮 -->
      <div class="operation-buttons">
        <el-button type="primary" @click="handleAdd">新增</el-button>
        <el-button type="danger" @click="handleBatchDelete" :disabled="!selectedIds.length">
          批量删除
        </el-button>
      </div>

      <!-- 数据表格 -->
      <el-table v-loading="loading" :data="userList" @selection-change="handleSelectionChange" stripe>
        <el-table-column type="selection" width="55" align="center" />
        <el-table-column label="序号" width="55" align="center">
          <template #default="{ $index }">
            {{ (queryParams.current - 1) * queryParams.size + $index + 1 }}
          </template>
        </el-table-column>
        <el-table-column label="姓名" prop="name" align="center" />
        <el-table-column label="年龄" prop="age" align="center" />
        <el-table-column label="状态" prop="state" align="center">
          <template #default="{ row }">
            <el-tag :type="stateTagType[row.state]">
              {{ stateFormat(row.state) }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="处理环节" align="center" width="150">
          <template #default="{ row }">
            <template v-if="row.handler">
              <el-tooltip :content="row.handlerName" placement="top">
                <span>待
                  <span class="handler-text">
                    {{ row.handlerName.slice(0, 2) }}...
                  </span>
                  处理
                </span>
              </el-tooltip>
            </template>
            <span v-else>
              -
            </span>
          </template>
        </el-table-column>
        <el-table-column label="操作" align="left" width="240">
          <template #default="{ row }">
            <div style="display: flex; gap: 8px;">
              <div v-if="row.state === 1">
                <el-button link type="primary" @click="handleEdit(row)">
                  审批
                </el-button>
                <el-button link type="danger" @click="handleRevoke(row)">撤销</el-button>
              </div>
              <div v-else-if="[0, 4].includes(row.state)">
                <el-button link type="primary" @click="handleEdit(row)">
                  编辑
                </el-button>
                <el-button link type="danger" @click="handleDelete(row)">
                  删除
                </el-button>
              </div>
              <el-button link type="primary" @click="handleDetail(row)">详情</el-button>
            </div>
          </template>
        </el-table-column>
      </el-table>

      <Pagination
        v-model:page="queryParams.current"
        v-model:limit="queryParams.size"
        :total="total"
        @pagination="getList"
      />
    </ContentWrap>

    <!-- 新增/编辑弹窗 -->
    <el-dialog :title="dialog.title" v-model="dialog.visible" width="500px" @close="resetForm">
      <el-form ref="formRef" :model="formData" :rules="rules" label-width="80px" @close="resetForm">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="formData.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="年龄" prop="age">
          <el-input-number v-model="formData.age" :min="0" :controls="false" />
        </el-form-item>
      </el-form>
      <WorkFlowPro :processKey="formData.processKey" :businessKey="formData.id" :status="formData.state" :on-submit="submitForm"
        :on-save="submitForm" :on-approve="submitForm" @cancel="dialog.visible = false" @refresh="resetQuery" />
    </el-dialog>

    <el-drawer :title="drawer.title" v-model="drawer.visible" size="40%">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="姓名">{{ formData.name }}</el-descriptions-item>
        <el-descriptions-item label="年龄">{{ formData.age }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="stateTagType[formData.state]">
            {{ stateFormat(formData.state) }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
      <WorkFlowPro :businessKey="formData.id" :status="formData.state" :readonly="true" />
    </el-drawer>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { WorkFlowPro } from '@/components/WorkFlow'
import {
  pageUser,
  addUser,
  updateUser,
  delUser,
  delUserBatch
} from '@/api/workflow'
import { revokeProcess } from '@/api/workflow'

// 状态选项配置
const stateOptions = [
  { value: 0, label: '暂存' },
  { value: 1, label: '审批中' },
  { value: 2, label: '审批通过' },
  { value: 3, label: '审批拒绝' },
  { value: 4, label: '已驳回' }
]

const stateTagType = {
  0: 'info',
  1: 'warning',
  2: 'success',
  3: 'danger',
  4: 'danger'
}

// 数据列表相关
const loading = ref(false)
const userList = ref([])
const selectedIds = ref([])
const total = ref(0)

// 查询参数
const queryParams = reactive({
  current: 1,
  size: 10,
  name: '',
  state: null
})

// 弹窗相关
const dialog = reactive({
  visible: false,
  title: '',
})

// 抽屉相关
const drawer = reactive({
  visible: false,
  title: '',
})

// 表单数据
const formData = reactive({
  processKey: 'FlowUser',
  id: null,
  name: '',
  age: 0,
})

// 表单验证规则
const rules = {
  name: [{ required: true, message: '姓名不能为空', trigger: 'blur' }],
  age: [{ required: true, message: '年龄不能为空', trigger: 'blur' }],
}

// 生命周期钩子
onMounted(() => {
  getList()
})

// 获取数据列表
const getList = async () => {
  try {
    loading.value = true
    const res = await pageUser({
      ...queryParams
    })
    userList.value = res.records
    total.value = res.total
  } finally {
    loading.value = false
  }
}

// 处理分页变化
const handlePagination = (current) => {
  queryParams.current = Number(current);
  queryParams.size = Number(queryParams.size); // 若 size 可调则需处理
  getList();
};

// 状态格式化
const stateFormat = (state) => {
  return stateOptions.find(item => item.value === state)?.label || '未知'
}

// 处理搜索
const handleQuery = () => {
  queryParams.current = 1
  getList()
}

// 重置搜索
const resetQuery = () => {
  queryParams.current = 1
  queryParams.name = ''
  queryParams.state = null
  getList()
}

// 处理多选
const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id)
}

// 打开新增弹窗
const handleAdd = () => {
  dialog.title = '新增用户'
  dialog.visible = true
  resetForm()
}

// 打开编辑弹窗
const handleEdit = (row) => {
  dialog.title = '编辑用户'
  Object.assign(formData, row)
  dialog.visible = true
}

// 打开详情弹窗
const handleDetail = (row) => {
  drawer.title = `用户【${row.name}】详情`
  Object.assign(formData, row)
  drawer.visible = true
}

// 提交表单
const submitForm = async () => {
  try {
    var result = {}
    if (formData.id) {
      result = await updateUser(formData)
    } else {
      result = await addUser(formData)
    }
    return result
  } catch (error) {
    console.error('操作失败:', error)
  }
}

// 重置表单
const resetForm = () => {
  formData.id = null
  formData.name = ''
  formData.age = null
  formData.state = 0
}

// 删除单个
const handleDelete = async (row) => {
  try {
    await ElMessageBox.confirm(`确认删除用户【${row.name}】吗？`, '提示', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await delUser(row.id)
    ElMessage.success('删除成功')
    getList()
  } catch { }
}

// 批量删除
const handleBatchDelete = async () => {
  try {
    await ElMessageBox.confirm('确认删除选中的数据吗？', '提示', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await delUserBatch(selectedIds.value)
    ElMessage.success('删除成功')
    getList()
  } catch { }
}

const handleRevoke = async (row) => {
  try {
    await ElMessageBox.confirm(`确认撤销用户【${row.name}】流程吗？`, '提示', {
      confirmButtonText: '确认',
      cancelButtonText: '取消',
      type: 'warning'
    })
    await revokeProcess(row.id)
    ElMessage.success('撤销成功')
    getList()
  } catch { }
};
</script>

<style scoped>
.app-container {
}

.handler-text {
  color: #245ff2;
  cursor: pointer;
}

.search-form {
  margin-bottom: 20px;
}

.operation-buttons {
  margin-bottom: 10px;
}
</style>