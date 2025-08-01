import { useCache, CACHE_KEY } from '@/hooks/web/useCache'
import { TokenType } from '@/api/login/types'
import { decrypt, encrypt } from '@/utils/jsencrypt'
import { useTagsViewStore } from '@/store/modules/tagsView'
import { unref } from 'vue'
const { wsCache } = useCache()

const AccessTokenKey = 'ACCESS_TOKEN'
const RefreshTokenKey = 'REFRESH_TOKEN'

// 获取token
export const getAccessToken = () => {
  // 此处与TokenKey相同，此写法解决初始化时Cookies中不存在TokenKey报错
  const accessToken = wsCache.get(AccessTokenKey)
  return accessToken ? accessToken : wsCache.get('ACCESS_TOKEN')
}

// 刷新token
export const getRefreshToken = () => {
  return wsCache.get(RefreshTokenKey)
}

// 设置token
export const setToken = (token: TokenType) => {
  wsCache.set(RefreshTokenKey, token.refreshToken)
  wsCache.set(AccessTokenKey, token.accessToken)
}

export const closeSelectTag = (currentRoute) => {
  const tagsViewStore = useTagsViewStore()
  tagsViewStore.delView(unref(currentRoute))
}
// import * as themeAll from "@/styles/theme.scss";
// const getChartColor = (key) => {

//   let classList = document.documentElement.classList
//   let arr = []
//   for (let i = 0; i < classList.length; i++) {
//     arr.push(classList[i])
//   }
//   let dictTheme = {}
//   if (arr.includes('dark')) {
//     dictTheme = themeAll.black
//   } else {
//     dictTheme = themeAll.white
//   }
//   return dictTheme[key]
// }

// 删除token
export const removeToken = () => {
  wsCache.delete(AccessTokenKey)
  wsCache.delete(RefreshTokenKey)
}

/** 格式化token（jwt格式） */
export const formatToken = (token: string): string => {
  return 'Bearer-tdx ' + token
}
// ========== 账号相关 ==========

export type LoginFormType = {
  tenantName: string
  username: string
  password: string
  rememberMe: boolean
}

export const getLoginForm = () => {
  const loginForm: LoginFormType = wsCache.get(CACHE_KEY.LoginForm)
  if (loginForm) {
    loginForm.password = decrypt(loginForm.password) as string
  }
  return loginForm
}

export const setLoginForm = (loginForm: LoginFormType) => {
  loginForm.password = encrypt(loginForm.password) as string
  wsCache.set(CACHE_KEY.LoginForm, loginForm, { exp: 30 * 24 * 60 * 60 })
}

export const removeLoginForm = () => {
  wsCache.delete(CACHE_KEY.LoginForm)
}

// ========== 租户相关 ==========

export const getTenantId = () => {
  return wsCache.get(CACHE_KEY.TenantId)
}

export const setTenantId = (username: string) => {
  wsCache.set(CACHE_KEY.TenantId, username)
}
