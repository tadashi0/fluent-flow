<template>
  <div class="node-wrap">
    <div class="node-wrap-box">
      <div class="title" style="background: #909399;">
        <span>{{ nodeConfig.nodeName }}</span>
      </div>
      <div class="content">
        <span class="placeholder">流程结束</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue';

const props = defineProps({
  modelValue: {
    type: Object,
    default: () => ({})
  }
});

const nodeConfig = ref({});

watch(() => props.modelValue, (newVal) => {
  nodeConfig.value = newVal;
}, { immediate: true });

</script>

<style>
</style>