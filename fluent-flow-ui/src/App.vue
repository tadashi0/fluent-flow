<script lang="ts" setup>
import { isDark } from '@/utils/is'
import { useAppStore } from '@/store/modules/app'
import { useDesign } from '@/hooks/web/useDesign'
import { CACHE_KEY, useCache } from '@/hooks/web/useCache'
import routerSearch from '@/components/RouterSearch/index.vue'
import { onMounted, onUnmounted, ref } from 'vue'

defineOptions({ name: 'APP' })

const { getPrefixCls } = useDesign()
const prefixCls = getPrefixCls('app')
const appStore = useAppStore()
const currentSize = computed(() => appStore.getCurrentSize)
const greyMode = computed(() => appStore.getGreyMode)
const { wsCache } = useCache()

// 根据浏览器当前主题设置系统主题色
const setDefaultTheme = () => {
  let isDarkTheme = wsCache.get(CACHE_KEY.IS_DARK)
  if (isDarkTheme === null) {
    isDarkTheme = isDark()
  }
  appStore.setIsDark(isDarkTheme)
}
setDefaultTheme()

// 全局缩放逻辑
const scale = ref(1)
const updateScale = () => {
  const designWidth = 1920 // 设计宽度
  const currentWidth = window.innerWidth
  scale.value = currentWidth / designWidth

  // 调整 body 高度以匹配比例，防止内容被裁剪
  document.body.style.height = `${window.innerHeight / scale.value}px`
}

onMounted(() => {
  updateScale()
  window.addEventListener('resize', updateScale)
})

onUnmounted(() => {
  window.removeEventListener('resize', updateScale)
})
</script>
<template>
  <ConfigGlobal :size="currentSize">
    <div
      :style="{
        transform: `scale(${scale})`,
        transformOrigin: 'top left',
        width: '1920px',
        height: '100%'
      }"
    >
      <RouterView :class="greyMode ? `${prefixCls}-grey-mode` : ''" />
      <routerSearch />
    </div>
  </ConfigGlobal>
</template>
<style lang="scss">
$prefix-cls: #{$namespace}-app;

.size {
  width: 100%;
  height: 100%;
}

html,
body {
  @extend .size;

  padding: 0 !important;
  margin: 0;
  overflow: hidden;

  #app {
    @extend .size;
  }
}

.#{$prefix-cls}-grey-mode {
  filter: grayscale(100%);
}
</style>
