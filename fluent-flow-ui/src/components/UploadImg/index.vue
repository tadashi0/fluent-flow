<template>
  <div>
    <div style="width: 100%;">
      <el-button type="primary" @click="open">
        {{ imgTitle }}
      </el-button>
      <img class="block mb-[15px] rounded-full w-full" :src="resImg" v-if="resImg" />
    </div>
    <el-dialog :title="imgTitle" v-model="visible" width="800px" append-to-body>
      <el-row>
        <el-col :xs="24" :md="12" :style="{ height: '350px' }">
          <!-- 裁剪区域 -->
          <div
            style="width: 100%; height: 100%; overflow: hidden;display: flex;justify-content: center;align-items: center;">
            <img v-if="preImage" :src="preImage" alt="裁剪图片" style="border-radius: unset;"
              class="block mb-[15px] rounded-full max-w-full max-h-full object-contain" />
          </div>
        </el-col>
        <el-col :xs="24" :md="12" style="display: flex; justify-content: center; align-items: center;"
          :style="{ height: '350px' }">
          <div style="width: 360px; height: 120px; box-shadow: 0 0 4px #ccc; overflow: hidden;"
            :style="{ width: imageWidth + 'px', height: imageHeight + 'px' }">
            <canvas @wheel="handleWheel" @mouseup="handleMouseUp" @mousedown="handleMouseDown"
              @mousemove="handleMouseMove" ref="canvasRef" :width="imageWidth" :height="imageHeight"></canvas>
          </div>
        </el-col>
      </el-row>
      <br />
      <el-row style="width: 100%; display: flex; justify-content: space-around; align-items: center;">
        <el-col :lg="2" :md="2">
          <el-upload action="#" :http-request="requestUpload" :show-file-list="false" :before-upload="beforeUpload">
            <el-button size="small" type="primary">
              选择
            </el-button>
          </el-upload>
        </el-col>
        <el-col :lg="{ span: 2, offset: 6 }" :md="2">
          <el-button type="primary" size="small" @click="uploadImg">保 存</el-button>
        </el-col>
      </el-row>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
const message = useMessage() // 消息弹窗
import { dataURLtoBlob } from "@/utils/filt";
import { ref } from "vue";

//接口参数地址未知，临时接口
const request = async ({ url, method, data }) => {
  console.log("request", url, method, data);
  return new Promise((resolve) => {
    //data是formData格式，取出图片
    const file = data.get("file");
    //将file存到浏览器本地
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = (e) => {
      const img = new Image();
      img.src = e.target.result as string;
      img.onload = () => {
        resolve(img.src);
      }
    }
  });
}

// Props 定义
const props = defineProps({
  imageWidth: {
    type: Number,
    default: 360,
  },
  imageHeight: {
    type: Number,
    default: 120,
  },
  imgTitle: {
    type: String,
    default: "上传封面",
  },
  uploadUrl: {
    type: String,
    default: "",
  }
});

// 状态变量
const visible = ref(false);
const preImage = ref<string | null>(null); // 当前裁剪图片的 URL
const previews = ref<string | null>(null);  // 裁剪预览对象
const resImg = ref<string | null>(null); // 上传后的图片地址
const isDragging = ref(false); // 是否正在拖拽
const startX = ref(0); // 拖拽开始时的 X 坐标
const startY = ref(0); // 拖拽开始时的 Y 坐标
const offsetX = ref(0); // 裁剪框相对于图片左上角的 X 偏移量
const offsetY = ref(0); // 裁剪框相对于图片左上角的 Y 偏移量
const ratio = ref(1); //图片比例

//引用的组件
const canvasRef = ref<HTMLCanvasElement | null>(null);
// 方法定义

//打开组件
const open = () => {
  init();
  visible.value = true;
}

//初始化组件
const init = () => {
  preImage.value = null;
  previews.value = null;
  resImg.value = null;
  isDragging.value = false;
  startX.value = 0;
  startY.value = 0;
  offsetX.value = 0;
  offsetY.value = 0;
  ratio.value = 1;
  //清除canvas
  const canvas = canvasRef.value;
  if (canvas) {
    const ctx = canvas.getContext("2d");
    ctx.clearRect(0, 0, canvas.width, canvas.height);
  }
}

//加载图片
const loadImage = (url: string) => {
  const img = new Image();
  img.src = url;
  img.onload = () => {
    drawImageOnCanvas(img);
  };
  img.onerror = () => {
    message.error("图片加载失败");
  };
}

//在canvas上绘制图片
const drawImageOnCanvas = (img: HTMLImageElement) => {
  if (!img) return;
  const canvas = canvasRef.value;
  const ctx = canvas.getContext("2d");
  // 清空画布
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  // 根据用户设置比例ratio截取图片并绘制
  const x = offsetX.value * ratio.value;
  const y = offsetY.value * ratio.value;
  const width = props.imageWidth * ratio.value;
  const height = props.imageHeight * ratio.value;
  //解释参数：img, x, y, width, height, 0, 0, props.imageWidth, props.imageHeight
  //img是图片对象，剩余参数前四个参数是图片的坐标和宽高，后四个参数是canvas的坐标和宽高
  ctx.drawImage(img, x, y, width, height, 0, 0, props.imageWidth, props.imageHeight);
}

//拖拽事件
const handleMouseDown = (event: MouseEvent) => {
  startX.value = event.clientX;
  startY.value = event.clientY;
  isDragging.value = true;
}

const handleMouseMove = (event: MouseEvent) => {
  if (!isDragging.value) return;
  const deltaX = event.clientX - startX.value;
  const deltaY = event.clientY - startY.value;
  startX.value = event.clientX;
  startY.value = event.clientY;
  offsetX.value -= deltaX;
  offsetY.value -= deltaY;
}

const handleMouseUp = () => {
  isDragging.value = false;
  loadImage(previews.value)
}

const handleWheel = (event: WheelEvent) => {
  //判断滚动方向
  if (event.deltaY < 0) {
    ratio.value += 0.1;
  } else {
    ratio.value -= 0.1;
  }
  loadImage(previews.value)
}

//临时上传路径
const requestUpload = (event): Promise<void> => {
  const file = event.file;
  const tempUrl = URL.createObjectURL(file);
  return new Promise((resolve) => {
    previews.value = tempUrl;
    preImage.value = tempUrl;
    loadImage(tempUrl);
    resolve();
  });
};

//判断文件格式
const beforeUpload = (file: File) => {
  if (!file.type.includes("image/")) {
    message.error("文件格式错误，请上传图片类型，如：JPG，PNG后缀的文件。");
    return false;
  }
};

const uploadImg = () => {

  //获取当前canvas的画面
  const canvas = canvasRef.value;
  const imgData = canvas.toDataURL("image/png");
  //将imgData转为blob对象
  const blob = dataURLtoBlob(imgData);
  //将blob对象转为file对象
  const file = new File([blob], "image.png", { type: "image/png" });
  //将file对象转为FormData对象
  const formData = new FormData();
  formData.append("file", file);
  //上传图片
  request({
    url: "/file/upload",
    method: "post",
    data: formData,
  }).then((res: string) => {
    emit("backValue", res);
    visible.value = false;
  });
};

// 事件触发器
const emit = defineEmits(["backValue"]);
</script>

<style scoped lang="scss">
.user-info-head {
  position: relative;
  display: inline-block;
  height: 120px;
}

.user-info-head:hover:after {
  content: "+";
  position: absolute;
  left: 0;
  right: 0;
  top: 0;
  bottom: 0;
  color: #eee;
  background: rgba(0, 0, 0, 0.5);
  font-size: 24px;
  font-style: normal;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  cursor: pointer;
  line-height: 110px;
  border-radius: 50%;
}
</style>