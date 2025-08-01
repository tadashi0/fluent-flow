<template>
  <Dialog v-model="dialogVisible" :title="title" width="400">
    <el-upload ref="uploadRef" v-model:file-list="fileList" :action="importUrl + '?updateSupport=' + updateSupport"
      :auto-upload="false" :disabled="formLoading" :headers="uploadHeaders" :limit="1" :on-error="submitFormError"
      :on-exceed="handleExceed" :on-success="submitFormSuccess" accept=".xlsx, .xls" drag>
      <Icon icon="ep:upload" />
      <div class="el-upload__text">将文件拖到此处，或<em>点击上传</em></div>
      <template #tip>
        <div class="el-upload__tip text-center">
          <div class="el-upload__tip">
            <el-checkbox v-model="updateSupport" />
            是否更新已经存在的用户数据
          </div>
          <span>仅允许导入 xls、xlsx 格式文件。</span>
          <el-link :underline="false" style="font-size: 12px; vertical-align: baseline" type="primary"
            @click="importTemplate">
            下载模板
          </el-link>
        </div>
      </template>
    </el-upload>
    <template #footer>
      <el-button :disabled="formLoading" type="primary" @click="submitForm">确 定</el-button>
      <el-button @click="dialogVisible = false">取 消</el-button>
    </template>
  </Dialog>
</template>
<script lang="ts" setup>
// @ts-nocheck
import { getAccessToken, getTenantId } from '@/utils/auth'
import download from '@/utils/download'
import request from '@/config/axios'
defineOptions({ name: 'ImportFormData' })

const pushUrl = ref('')
const title = ref('')
const templateName = ref('')
const templateUrl = ref('')

const message = useMessage() // 消息弹窗

const dialogVisible = ref(false) // 弹窗的是否展示
const formLoading = ref(false) // 表单的加载中
const uploadRef = ref()
const importUrl = ref('')
const uploadHeaders = ref() // 上传 Header 头
const fileList = ref([]) // 文件列表
const updateSupport = ref(0) // 是否更新已经存在的用户数据
const url1 = import.meta.env.VITE_BASE_URL
const url2 = import.meta.env.VITE_API_URL
/** 打开弹窗
 * pushUrl: 上传的 URL
 * title: 弹窗的标题
 * templateName: 模板的名称
 * templateUrl: 模板的下载 URL
 */
const open = (result) => {
  importUrl.value = url1 + url2 + result.pushUrl
  title.value = result.title
  templateName.value = result.templateName
  templateUrl.value = result.templateUrl
  dialogVisible.value = true
  updateSupport.value = 0
  fileList.value = []
  resetForm()
}
defineExpose({ open }) // 提供 open 方法，用于打开弹窗

/** 提交表单 */
const submitForm = async () => {
  if (fileList.value.length == 0) {
    message.error('请上传文件')
    return
  }
  // 提交请求
  uploadHeaders.value = {
    Authorization: 'Bearer-tdx ' + getAccessToken(),
    'tenant-id': getTenantId()
  }
  formLoading.value = true
  uploadRef.value!.submit()
}

/** 文件上传成功 */
const emits = defineEmits(['success'])
const submitFormSuccess = (response: any) => {
  if (response.code !== 0) {
    message.error(response.msg)
    formLoading.value = false
    return
  }
  // 拼接提示语
  const data = response.data
  let text = '导入成功'
  message.success(text)
  formLoading.value = false
  dialogVisible.value = false
  // 发送操作成功的事件
  emits('success')
}

/** 上传错误提示 */
const submitFormError = (): void => {
  message.error('上传失败，请您重新上传！')
  formLoading.value = false
}

/** 重置表单 */
const resetForm = async (): Promise<void> => {
  // 重置上传状态和文件
  formLoading.value = false
  await nextTick()
  uploadRef.value?.clearFiles()
}

/** 文件数超出提示 */
const handleExceed = (): void => {
  message.error('最多只能上传一个文件！')
}

/** 下载模板操作 */
const importTemplate = async () => {
  const res = await request.download({ url: templateUrl.value })
  download.excel(res, templateName.value + '.xls')
}
</script>
