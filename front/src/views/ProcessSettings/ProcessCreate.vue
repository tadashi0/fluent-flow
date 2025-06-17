<template>
    <div class="process-create-container">
        <div class="step-button-container">
            <!-- Left-aligned back button -->
            <div class="left-actions">
                <el-button @click="() => router.back({ query: { processKey: formData.processKey } })">返回</el-button>
            </div>
            
            <!-- Centered steps -->
            <div class="center-steps">
                <el-steps :active="step" align-center>
                    <el-step title="基础信息" @click="handleStepChange(1)"></el-step>
                    <el-step title="流程设计" @click="handleStepChange(2)"></el-step>
                </el-steps>
            </div>
            
            <!-- Right-aligned actions (always present) -->
            <div class="right-actions">
                <el-button 
                    v-if="step === 2" 
                    type="primary" 
                    @click="handleSubmit"
                >
                    发布
                </el-button>
            </div>
        </div>

        <div class="form-content">
            <!-- 第一步：基础信息 -->
            <div class="form-wrapper" v-if="step === 1">
                <el-form 
                    :model="formData" 
                    :rules="formRules"
                    ref="formRef"
                    label-width="120px"
                    @validate="onValidate"
                >
                    <el-form-item label="流程名称" prop="processName" required>
                        <el-input 
                            v-model="formData.processName" 
                            placeholder="请输入流程名称" 
                            clearable
                        />
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

            <!-- 第二步：流程设计 -->
            <div v-if="step === 2" class="workflow-container">
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
import WorkFlow from '@/components/workFlow.vue'
import { getTableList, createProcess, getProcessInfo } from '@/api/process'
import { ElMessage } from 'element-plus'
import { debounce } from 'lodash-es'

const route = useRoute()
const router = useRouter()
const step = ref(1)
const tableNames = ref([])
const tableLoading = ref(false)
const formRef = ref(null) // Form reference for validation

// 表单验证规则
const formRules = {
    processName: [
        { required: true, message: '请输入流程名称', trigger: 'blur' },
        { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
    ],
    processType: [
        { required: true, message: '请选择数据库表', trigger: 'change' }
    ],
    useScope: [
        { required: true, message: '请选择流程类型', trigger: 'change' }
    ]
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
    if(!route.query?.id) return
    const { data } = await getProcessInfo(route.query?.id)
    formData.value = {...data, module: JSON.parse(data.modelContent)?.module || ''}
})

const tableName = computed(() => formData.value.processType)
provide('tableName', tableName)

// 流程设计组件引用
const workflowRef = ref(null)

const handleStepChange = async (newStep) => {
    if (newStep === 2) {
        // 切换到第二步前先验证第一步的表单
        try {
            await formRef.value.validate()
            step.value = newStep
        } catch (error) {
            ElMessage.warning('请先完善基本信息')
        }
    } else if (newStep >= 1 && newStep <= 2) {
        step.value = newStep
    }
}

const onValidate = (prop, isValid) => {
    if (!isValid) {
        console.log(`Field ${prop} validation failed`)
    }
}

const handleSubmit = async () => {
    try {
        // 如果是第一步，验证表单
        if (step.value === 1) {
            await formRef.value.validate()
            step.value = 2
            return
        }
        
        // 如果是第二步，提交数据
        const workflowData = workflowRef.value?.getWorkflowData()
        if (!workflowData) {
            ElMessage.warning('请先设计流程')
            return
        }

        const submitData = {
            ...formData.value,
            modelContent: JSON.stringify({ ...workflowData, key: formData.value.useScope === 1 ? formData.value.processId ? formData.value.processKey : formData.value.processKey + '-' + Date.now() : formData.value.processKey })
        }
        
        // 调用提交接口
        await createProcess(submitData)
        ElMessage.success('流程创建成功')

        step.value = 1
        router.push({
            name: 'ProcessSettings',
            query: {
                processKey: formData.value.processKey?.split('-')[0] || formData.value.processKey
            }
        })
    } catch (error) {
        console.error('提交失败:', error)
    }
}

// 添加防抖搜索方法（300毫秒间隔）
const handleTableSearch = debounce(async (query) => {
    try {
        tableLoading.value = true
        const res = await getTableList({ tableName: query })
        tableNames.value = res.data || []
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
.process-create-container {
  padding: 24px 32px;
  margin: 0 auto;
  background: #f5f7fa;
  min-height: 100vh;
}

.step-button-container {
  position: sticky;
  top: 0;
  z-index: 10;
  background: #fff;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 24px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  border-radius: 8px;
  margin-bottom: 24px;
}

.left-actions,
.right-actions {
  width: 120px;
}

.center-steps {
    flex: 1;
    max-width: 500px;
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

.form-content {
  margin-top: 20px;
}

.el-input,
.el-select,
.el-textarea {
  width: 100%;
}
</style>