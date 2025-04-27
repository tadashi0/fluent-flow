<template>
    <div class="process-create-container">
        <div class="step-button-container">
            <!-- Left-aligned back button -->
            <div class="left-actions">
                <el-button @click="() => router.back({ query: { componentName } })">返回</el-button>
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
                        <el-input v-model="formData.processKey" disabled />
                    </el-form-item>

                    <el-form-item label="数据库表" prop="processType" required>
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
                />
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import WorkFlow from '@/components/workFlow.vue'
import { getTableList, createProcess } from '@/api/process'
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
}

// 从路由参数获取组件名称
const componentName = computed(() => route.query?.componentName || '')

// 从路由参数获取编辑数据并初始化表单
const editData = computed(() => {
    try {
        return route.query?.editData ? JSON.parse(route.query.editData) : null
    } catch {
        return null
    }
})

// 初始化表单数据
const initFormData = computed(() => {
    if (editData.value) {
        return {
            processName: editData.value.processName,
            processKey: editData.value.processKey,
            processType: editData.value.processType,
            remark: editData.value.remark || '',
            modelContent: editData.value.modelContent || ''
        }
    }
    return {
        processName: '',
        processKey: componentName.value,
        processType: '',
        remark: '',
        modelContent: ''
    }
})

// 表单数据
const formData = ref(initFormData.value)

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
            modelContent: workflowData
        }
        
        // 调用提交接口
        await createProcess(submitData)
        ElMessage.success('流程创建成功')

        // 提交成功后跳转回流程列表
        formData.value = {
            processName: '',
            description: ''
        }
        step.value = 1
        router.push({
            name: 'ProcessSettings',
            query: {
                componentName: componentName.value
            }
        })
    } catch (error) {
        console.error('提交失败:', error)
        if (error?.errors) {
            ElMessage.error('请检查表单填写是否正确')
        } else {
            ElMessage.error('提交失败: ' + (error.message || '未知错误'))
        }
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
    padding: 24px;
    width: 100%;
    margin: 0 auto;
}

.step-button-container {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px;
    margin: 0 auto;
}

.left-actions {
    width: 120px; /* Match button width */
}

.center-steps {
    flex: 1;
    max-width: 500px;
    margin: 0 20px;
}

.right-actions {
    width: 120px; /* Match button width */
    display: flex;
    justify-content: flex-end;
}

.form-content {
    margin-top: 32px;
    margin: 0 auto;
}

.form-wrapper {
    width: 600px;
    height: 500px;
    margin: 0 auto;
    padding: 24px;
    background: #fff;
    border-radius: 8px;
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.el-input {
    width: 100%;
}

.workflow-container {
    width: 100%;
}

.action-bar {
    margin-top: 24px;
    text-align: right;
}
</style>