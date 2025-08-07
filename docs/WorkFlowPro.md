
# 📦 WorkFlowPro 组件使用文档

`WorkFlowPro` 是一个用于集成工作流流程操作的通用组件，适用于流程的发起、审批、保存草稿、只读查看等场景。

## ✅ 引入组件

```vue
import { WorkFlowPro } from '@/components/WorkFlow'
```

## 🧩 基本用法

### 📌 表单内嵌使用（新增/编辑）

```vue
<el-dialog :title="dialog.title" v-model="dialog.visible" width="500px" @close="resetForm">
  <el-form ref="formRef" :model="formData" :rules="rules" label-width="80px">
    <el-form-item label="姓名" prop="name">
      <el-input v-model="formData.name" placeholder="请输入姓名" />
    </el-form-item>
    <el-form-item label="年龄" prop="age">
      <el-input-number v-model="formData.age" :min="0" :controls="false" />
    </el-form-item>
  </el-form>

  <!-- 嵌入工作流组件 -->
  <WorkFlowPro
    :processKey="formData.processKey"
    :businessKey="formData.id"
    :status="formData.state"
    :on-submit="submitForm"
    :on-save="submitForm"
    :on-approve="submitForm"
    @cancel="dialog.visible = false"
    @refresh="resetQuery"
  />
</el-dialog>
```

### 📌 详情/只读模式使用

```vue
<el-drawer :title="drawer.title" v-model="drawer.visible" size="40%">
  <el-descriptions :column="1" border>
    <el-descriptions-item label="姓名">{{ formData.name }}</el-descriptions-item>
    <el-descriptions-item label="年龄">{{ formData.age }}</el-descriptions-item>
    <el-descriptions-item label="状态">
      <el-tag :type="stateTagType[formData.state]">{{ stateFormat(formData.state) }}</el-tag>
    </el-descriptions-item>
  </el-descriptions>

  <!-- 只读模式下展示流程轨迹等 -->
  <WorkFlowPro
    :businessKey="formData.id"
    :status="formData.state"
    :readonly="true"
  />
</el-drawer>
```

## 🧾 Props 参数说明

| 参数名        | 说明                             | 类型       | 是否必传 | 示例值             |
|---------------|----------------------------------|------------|----------|--------------------|
| `processKey`  | 流程定义标识，用于启动流程       | `string`   | 是       | `'user-process'`   |
| `businessKey` | 业务主键，用于关联业务表         | `string`/`number` | 是       | `formData.id`       |
| `status`      | 当前流程状态，用于控制按钮展示等 | `number`   | 否       | `1`（审批中）       |
| `readonly`    | 是否只读模式                     | `boolean`  | 否       | `true`             |
| `on-submit`   | 提交流程时的回调（发起/提交）    | `Function` | 否       | `submitForm`       |
| `on-save`     | 暂存流程时的回调                 | `Function` | 否       | `submitForm`       |
| `on-approve`  | 审批流程时的回调                 | `Function` | 否       | `submitForm`       |

## 📢 事件说明

| 事件名     | 说明                       | 回调参数         |
|------------|----------------------------|------------------|
| `@cancel`  | 点击取消关闭流程弹窗       | 无               |
| `@refresh` | 操作成功后通知刷新列表数据 | 无               |

## 📌 示例回调函数（`submitForm`）

```ts
const submitForm = async () => {
  try {
    let result;
    if (formData.id) {
      result = await updateUser(formData)
    } else {
      result = await addUser(formData)
    }
    return result.data // 必须返回主键ID（用于流程绑定）
  } catch (e) {
    console.error('操作失败', e)
  }
}
```

> ⚠️ 回调函数必须返回一个包含业务主键 ID 的值，否则工作流无法正确绑定业务数据。

## 📎 注意事项

- `processKey` 是工作流定义中配置的标识符，必须与流程引擎配置一致。
- 组件自动根据当前状态渲染流程按钮（如：提交、保存、审批、驳回等）。
- `readonly` 模式下只展示流程图与流转记录，不显示操作按钮。
- 搭配 FlowLong 或 Flowable 工作流引擎使用效果更佳。
