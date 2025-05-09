<template>
	<div class="add-node-btn-box">
		<div class="add-node-btn">
			<el-popover placement="right-start" :width="270" trigger="click" :hide-after="0" :show-after="0">
				<template #reference>
					<el-button type="primary" icon="el-icon-plus" circle></el-button>
				</template>
				<div class="add-node-popover-body">
					<ul style="padding-inline-start: 0px; margin-block-start: 0px; margin-block-end: 0px">
						<li>
							<el-icon style="color: #ff943e;" @click="addType(1)"><el-icon-user-filled /></el-icon>
							<p>审批节点</p>
						</li>
						<li>
							<el-icon style="color: #3296fa;" @click="addType(2)"><el-icon-promotion /></el-icon>
							<p>抄送节点</p>
						</li>
						<li>
							<el-icon style="color: #15BC83;" @click="addType(4)"><el-icon-share /></el-icon>
							<p>条件分支</p>
						</li>
						<li>
							<el-icon style="color: #9260FB;" @click="addType(5)"><el-icon-money /></el-icon>
							<p>子流程</p>
						</li>
						<li>
							<el-icon style="color: #F55266;" @click="addType(6)"><el-icon-clock /></el-icon>
							<p>延迟等待</p>
						</li>
						<li>
							<el-icon style="color: #38B58B;" @click="addType(7)"><el-icon-set-up /></el-icon>
							<p>触发器</p>
						</li>
						<li>
							<el-icon style="color: #67C23A;" @click="addType(30)"><el-icon-circle-check-filled /></el-icon>
							<p>自动通过</p>
						</li>
						<li>
							<el-icon style="color: #F56C6C;" @click="addType(31)"><el-icon-circle-close-filled /></el-icon>
							<p>自动拒绝</p>
						</li>
					</ul>
				</div>
			</el-popover>
		</div>
	</div>
</template>

<script>
export default {
	props: {
		modelValue: { type: Object, default: () => { } }
	},
	data() {
		return {

		}
	},
	mounted() {

	},
	methods: {
		getNodeKey() {
			return 'flk' + Date.now()
		},
		addType(type) {
			var node = {}
			if (type == 1) {
				node = {
					nodeName: "审批人",
					nodeKey: this.getNodeKey(),
					type: 1,			//节点类型
					setType: 4,			//审核人类型 1，选择成员 3，选择角色 4，发起人自选
					nodeAssigneeList: [],	//审核人员，根据 setType 确定成员还是角色
					examineLevel: 1,	//指定主管层级
					directorLevel: 1,	//自定义连续主管审批层级
					selectMode: 1,		//发起人自选类型
					termAuto: false,	//审批期限超时自动审批
					term: 0,			//审批期限
					termMode: 1,		//审批期限超时后执行类型
					examineMode: 1,		//多人审批时审批方式
					directorMode: 0,	//连续主管审批方式
					childNode: this.modelValue
				}
			} else if (type == 2) {
				node = {
					nodeName: "抄送人",
					nodeKey: this.getNodeKey(),
					type: 2,
					allowSelection: true,
					nodeAssigneeList: [],
					childNode: this.modelValue
				}

			} else if (type == 4) {
				node = {
					nodeName: "条件路由",
					nodeKey: this.getNodeKey(),
					type: 4,
					conditionNodes: [
						{
							nodeName: "条件1",
							nodeKey: this.getNodeKey(),
							type: 3,
							priorityLevel: 1,
							conditionMode: 1,
							conditionList: []
						},
						{
							nodeName: "条件2",
							nodeKey: 'flk' + (Date.now() + 1),
							type: 3,
							priorityLevel: 2,
							conditionMode: 1,
							conditionList: []
						}
					],
					childNode: this.modelValue
				}
			} else if (type == 5) {
				node = {
					nodeName: "子流程",
					nodeKey: this.getNodeKey(),
					type: 5,
					childNode: this.modelValue
				}
			} else if (type == 6) {
				node = {
					nodeName: "延时处理",
					nodeKey: this.getNodeKey(),
					type: 6,
					delayType: '1',
					extendConfig: {
						time: "0:m"
					},
					childNode: this.modelValue
				}
			} else if (type == 7) {
				node = {
					nodeName: "触发器",
					nodeKey: this.getNodeKey(),
					type: 7,
					triggerType: 1,
					delayType: '1',
					extendConfig: {
						time: "0:m"
					},
					childNode: this.modelValue
				}
			} else if (type == 30) {
				node = {
					nodeName: "自动通过",
					nodeKey: this.getNodeKey(),
					type: 30,
					childNode: this.modelValue
				}
			} else if (type == 31) {
				node = {
					nodeName: "自动拒绝",
					nodeKey: this.getNodeKey(),
					type: 31,
					childNode: this.modelValue
				}
			}
			this.$emit("update:modelValue", node)
		}
	}
}
</script>

<style></style>
