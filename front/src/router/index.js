import { createRouter, createWebHistory } from 'vue-router'
import WorkFlow from '@/components/workFlow.vue'
import TodoTasks from '@/views/ProcessCenter/TodoTasks.vue'
import DoneTasks from '@/views/ProcessCenter/DoneTasks.vue'
import SubmitTasks from '@/views/ProcessCenter/SubmitTasks.vue'
import AboutTasks from '@/views/ProcessCenter/AboutTasks.vue'
import Dashboard from '@/views/ProcessCenter/Dashboard.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/user'
    },
    {
      path: '/workflow',
      name: 'WorkFlow',
      component: WorkFlow
    },
    {
      path: '/user',
      name: 'FlowUser',
      component: () => import('@/views/FlowUser/index.vue')
    },
    {
      path: '/process',
      name: 'ProcessSettings',
      component: () => import('@/views/ProcessSettings/index.vue')
    },
    {
      path: '/process/create',
      name: 'ProcessCreate',
      component: () => import('@/views/ProcessSettings/ProcessCreate.vue')
    },
    {
      path: '/board',
      name: 'Dashboard',
      component: Dashboard
    },
    {
      path: '/todo',
      name: 'TodoTasks',
      component: TodoTasks
    },
    {
      path: '/done',
      name: 'DoneTasks',
      component: DoneTasks
    },
    {
      path: '/submit',
      name: 'SubmitTasks',
      component: SubmitTasks
    },
    {
      path: '/about',
      name: 'AboutTasks',
      component: AboutTasks
    },
  ]
})

export default router