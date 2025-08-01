<template>
  <div :id="randomId" type="text/plain" class="h-500px overflow-y-scroll"> </div>
</template>

<script>
import { ref, watch, onMounted, onBeforeUnmount } from 'vue'

export default {
  name: 'UE',
  props: {
    value: {
      type: String,
      default: ''
    }
  },
  emits: ['ready'], // 定义 emits
  setup(props, { emit }) {
    const randomId = ref('editor_' + Math.random() * 100000000000000000)
    const instance = ref(null)
    const ready = ref(false)

    // 监听 value 的变化
    watch(
      () => props.value,
      (val) => {
        if (val != null && ready.value && instance.value) {
          instance.value.setContent(val)
        }
      }
    )

    // 初始化编辑器
    const initEditor = () => {
      // eslint-disable-next-line no-undef
      instance.value = UE.getEditor(randomId.value)
      instance.value.addListener('ready', () => {
        ready.value = true
        emit('ready', instance.value) // 触发 ready 事件
      })
    }

    // 获取编辑器内容
    const getUEContent = () => {
      return instance.value ? instance.value.getContent() : ''
    }

    // 设置编辑器内容
    const setText = (content) => {
      if (instance.value) {
        instance.value.setContent(content)
      }
    }

    // 生命周期钩子
    onMounted(() => {
      initEditor()
    })

    onBeforeUnmount(() => {
      if (instance.value && instance.value.destroy) {
        instance.value.destroy()
      }
    })

    return {
      randomId,
      instance,
      ready,
      getUEContent,
      setText
    }
  }
}
</script>
