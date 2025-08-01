/**
 * Independent time operation tool to facilitate subsequent switch to dayjs
 */
// TODO 芋艿：【锁屏】可能后面删除掉
import dayjs from 'dayjs'

const DATE_TIME_FORMAT = 'YYYY-MM-DD HH:mm:ss'
const DATE_FORMAT = 'YYYY-MM-DD'

export function formatToDateTime(date?: dayjs.ConfigType, format = DATE_TIME_FORMAT): string {
  return dayjs(date).format(format)
}

export function formatToDate(date?: dayjs.ConfigType, format = DATE_FORMAT): string {
  return dayjs(date).format(format)
}

export function formatToDate2(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0'); // 月份从0开始，所以需要加1
  const day = String(date.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}


export const dateUtil = dayjs
