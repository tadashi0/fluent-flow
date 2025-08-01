<template>
  <div
    :class="prefixCls"
    class="fixed right-0 bottom-[5%] h-40px w-40px cursor-pointer bg-[var(--el-color-primary)] text-center leading-40px"
    @click="openAI"
  >
    <span style="color: #fff">AI</span>
  </div>
</template>

<script lang="ts" setup>
import { useDesign } from '@/hooks/web/useDesign'

defineOptions({ name: 'Robot' })

const { getPrefixCls } = useDesign()
const prefixCls = getPrefixCls('setting')
const drawer = ref(false)
const message = useMessage() // 消息
const route = useRoute() // 路由
// 打开弹窗
const openAI = () => {
  // 判断当前路由是否包含paperDo
  if (route.path.includes('paperDo')) {
    message.warning('考试中无法使用AI助手')
    return
  }
  drawer.value = true
}
// 关闭弹窗
const onBeforeDialogClose = async (onDone: () => {}) => {
  try {
    await message.confirm('确定关闭吗?')
    onDone()
  } catch {}
}
</script>
<style lang="scss" scoped>
$prefix-cls: #{$namespace}-setting;

.#{$prefix-cls} {
  border-radius: 6px 0 0 6px;
  z-index: 1200; /*修正没有z-index会被表格层覆盖,值不要超过4000*/
}

.ai-side {
  width: 100%;
  position: relative;
}
</style>
