<template>
  <div class="process-create-container" v-loading="submitLoading">
    <div class="tabs-header-wrapper">
      <!-- Left-aligned back button -->
      <div class="left-actions" style="width: 80px; margin-left: 24px">
        <!-- <el-button @click="() => router.back({ query: { processKey: formData.processKey } })">返回</el-button> -->
      </div>

      <!-- Tabs in center -->
      <div class="center-tabs">
        <el-tabs v-model="activeTab" @tab-change="handleTabChange" class="custom-tabs">
          <el-tab-pane label="① 基础设置" name="1" />
          <el-tab-pane label="② 流程设计" name="2" />
        </el-tabs>
      </div>

      <!-- Right-aligned actions -->
      <div class="right-actions" style="width: 80px">
        <el-button v-show="activeTab === '2'" type="primary" @click="handleSubmit" round>
          发布
        </el-button>
      </div>
    </div>

    <!-- Tab Content -->
    <div class="tab-content-wrapper">
      <!-- 基础设置内容 -->
      <div v-if="activeTab === '1'" class="tab-pane-content">
        <div class="form-wrapper">
          <el-form
            :model="formData"
            :rules="formRules"
            ref="formRef"
            label-width="120px"
            @validate="onValidate"
          >
            <el-form-item label="流程名称" prop="processName" required>
              <el-input v-model="formData.processName" placeholder="请输入流程名称" clearable />
            </el-form-item>

            <el-form-item label="所属模块" prop="processKey">
              <el-input v-model="formData.module" disabled />
            </el-form-item>

            <el-form-item label="流程类型" prop="useScope" required>
              <el-radio-group v-model="formData.useScope" :disabled="formData.processId">
                <el-radio :value="0">业务流程</el-radio>
                <el-radio :value="1">子流程</el-radio>
              </el-radio-group>
            </el-form-item>

            <el-form-item label="关联业务表" prop="processType" required>
              <el-select
                v-model="formData.processType"
                placeholder="请输入关键词搜索数据库表"
                filterable
                clearable
                remote
                reserve-keyword
                :remote-method="handleTableSearch"
                :loading="tableLoading"
              >
                <el-option
                  v-for="table in tableNames"
                  :key="table.tableName"
                  :label="`${table.tableName}（${table.tableComment || '无注释'}）`"
                  :value="table.tableName"
                />
              </el-select>
            </el-form-item>

            <el-form-item label="模型描述" prop="remark">
              <el-input
                v-model="formData.remark"
                type="textarea"
                :rows="4"
                placeholder="请输入流程描述"
                maxlength="200"
                show-word-limit
              />
            </el-form-item>
          </el-form>
        </div>
      </div>

      <!-- 流程设计内容 -->
      <div v-if="activeTab === '2'" class="tab-pane-content">
        <WorkFlow
          ref="workflowRef"
          :model-content="formData.modelContent"
          :process-name="formData.processName"
          :process-key="formData.processKey"
          :module="formData.module"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, provide, watchEffect } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { WorkFlow } from '@/components/WorkFlow'
import { getTableList, createProcess, getProcessInfo } from '@/api/workflow'
import { ElMessage } from 'element-plus'
import { debounce } from 'lodash-es'
import { useTagsViewStore } from '@/store/modules/tagsView'

defineOptions({ name: 'FlowCreate' })

const route = useRoute()
const router = useRouter()
const activeTab = ref('1') // 使用字符串类型的tab值
const tableNames = ref([])
const tableLoading = ref(false)
const formRef = ref(null) // Form reference for validation

// 表单验证规则
const formRules = {
  processName: [
    { required: true, message: '请输入流程名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  processType: [{ required: true, message: '请选择数据库表', trigger: 'change' }],
  useScope: [{ required: true, message: '请选择流程类型', trigger: 'change' }]
}

// 从路由参数获取组件名称
const processKey = computed(() => route.query?.processKey || '')
const module = computed(() => route.query?.module || '')

// 表单数据
const formData = ref({})

watchEffect(() => {
  formData.value = {
    processKey: route.query?.processKey || '',
    module: route.query?.module || '',
    processName: '',
    processType: '',
    useScope: 0,
    remark: '',
    modelContent: ''
  }
})

// 从路由参数获取编辑数据并初始化表单
watchEffect(async () => {
  if (!route.query?.id) return
  const data = await getProcessInfo(route.query?.id)
  formData.value = { ...data, module: JSON.parse(data.modelContent)?.module || '' }
})

const tableName = computed(() => formData.value.processType)
provide('tableName', tableName)

// 流程设计组件引用
const workflowRef = ref(null)

const handleTabChange = async (tabName) => {
  if (tabName === '2') {
    // 切换到第二个标签页前先验证第一步的表单
    try {
      await formRef.value.validate()
      activeTab.value = tabName
    } catch (error) {
      // 验证失败时，阻止切换并保持在当前标签页
      activeTab.value = '1'
      ElMessage.warning('请先完善基本信息')
    }
  } else {
    activeTab.value = tabName
  }
}

const onValidate = (prop, isValid) => {
  if (!isValid) {
    console.log(`Field ${prop} validation failed`)
  }
}

// 添加提交loading状态
const submitLoading = ref(false)

const tagsViewStore = useTagsViewStore()

const handleSubmit = async () => {
  try {
    submitLoading.value = true
    // 提交流程设计数据
    const workflowData = workflowRef.value?.getWorkflowData()
    if (!workflowData) {
      ElMessage.warning('请先设计流程')
      return
    }

    const submitData = {
      ...formData.value,
      modelContent: JSON.stringify({
        ...workflowData,
        key:
          formData.value.useScope === 1
            ? formData.value.processId
              ? formData.value.processKey
              : formData.value.processKey + '-' + Date.now()
            : formData.value.processKey
      })
    }

    // 调用提交接口
    await createProcess(submitData)
    ElMessage.success('流程创建成功')

    activeTab.value = '1'

    // 获取当前路由
    const currentRoute = router.currentRoute.value

    // 关闭当前新建流程的标签页
    tagsViewStore.delVisitedView(currentRoute)

    // 查找并关闭旧的流程设置标签页
    const oldSettingView = tagsViewStore.getVisitedViews.find((view) => view.name === 'FlowSetting')
    if (oldSettingView) {
      tagsViewStore.delVisitedView(oldSettingView)
    }

    // 跳转到流程设置页面
    router.push({
      name: 'FlowSetting',
      query: {
        processKey: formData.value.processKey?.split('-')[0] || formData.value.processKey
      }
    })
  } catch (error) {
    console.error('提交失败:', error)
  } finally {
    submitLoading.value = false
  }
}

// 添加防抖搜索方法（300毫秒间隔）
const handleTableSearch = debounce(async (query) => {
  try {
    tableLoading.value = true
    const res = await getTableList({ tableName: query })
    tableNames.value = res || []
  } catch (error) {
    console.error('搜索失败:', error)
    ElMessage.error('表格搜索失败')
  } finally {
    tableLoading.value = false
  }
}, 300)

// 在组件挂载时获取表名
onMounted(async () => {
  // 初始加载所有表格（传空参数）
  handleTableSearch('')
})
</script>

<style scoped>
/* 隐藏父级容器的滚动条 */
.process-create-container {
  display: flex;
  flex-direction: column;
}

.tabs-header-wrapper {
  background: #fff;
  display: flex;
  align-items: center;
  position: sticky;
  top: 0;
  padding: 0 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  z-index: 1;
}

.center-tabs {
  margin: 0 auto;
}

.tab-content-wrapper {
  margin-top: 20px;
}

:deep(.center-tabs .el-tabs__header) {
  margin: 0;
}

:deep(.center-tabs .el-tabs__nav-wrap) {
  display: flex;
  justify-content: center;
}

:deep(.center-tabs .el-tabs__nav-wrap::after) {
  display: none;
}

.form-wrapper {
  background: #fff;
  padding: 32px 40px;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
  width: 720px;
  margin: 0 auto;
  transition: all 0.3s ease;
}

.el-input,
.el-select,
.el-textarea {
  width: 100%;
}
</style>
