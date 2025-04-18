import { createRouter, createWebHistory } from 'vue-router'
import WorkFlow from '@/components/workFlow.vue'
import TodoTasks from '@/views/TodoTasks.vue'
import DoneTasks from '@/views/DoneTasks.vue'
import SubmitTasks from '@/views/SubmitTasks.vue'
import AboutTasks from '@/views/AboutTasks.vue'
import Dashboard from '@/views/Dashboard.vue'

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
      name: 'UserManagement',
      component: () => import('@/components/UserManagement.vue')
    },
    {
      path: '/process',
      name: 'ProcessSettings',
      component: () => import('@/components/ProcessSettings.vue')
    },
    {
      path: '/process/create',
      name: 'ProcessCreate',
      component: () => import('@/views/ProcessCreate.vue')
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