import { createApp } from 'vue'
// import './style.css'
import App from './App.vue'
import JsonEditorVue from 'json-editor-vue3'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import 'element-plus/dist/index.css'
import * as elIcons from '@element-plus/icons-vue'
import router from './router'

const app = createApp(App)

app.use(ElementPlus, {
  locale: zhCn,
})

app.use(JsonEditorVue)
app.use(ElementPlus)
app.use(router)

// 统一注册el图标
for (let icon in elIcons) {
  app.component(`ElIcon${icon}`, elIcons[icon])
}
app.mount('#app')
