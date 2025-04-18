<template>
  <div class="app-container">
    <nav class="nav-bar">
      <router-link to="/user" class="nav-item">用户管理</router-link>
      <!-- <router-link to="/workflow" class="nav-item">流程设计</router-link> -->
      <router-link to="/process" class="nav-item">流程设置</router-link>
      <router-link to="/board" class="nav-item">工作台</router-link>
      <router-link to="/todo" class="nav-item">待我处理</router-link>
      <router-link to="/done" class="nav-item">我已处理</router-link>
      <router-link to="/submit" class="nav-item">我发起的</router-link>
      <router-link to="/about" class="nav-item">抄送我的</router-link>
    </nav>
    <router-view />
  </div>
</template>

<style scoped>
.nav-bar {
  padding: 16px;
  background: #f5f7fa;
  border-bottom: 1px solid #e4e7ed;
}

.nav-item {
  margin-right: 24px;
  color: #606266;
  text-decoration: none;
}

.nav-item.router-link-exact-active {
  color: #409eff;
  font-weight: 500;
}
</style>

<script setup>
</script>
