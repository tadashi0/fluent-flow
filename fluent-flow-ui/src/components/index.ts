import type { App } from 'vue'
import { Icon } from './Icon'
import ImportData from './importData/index.vue'

export const setupGlobCom = (app: App<Element>): void => {
  app.component('Icon', Icon)
  app.component('HImportTable', ImportData)
}
