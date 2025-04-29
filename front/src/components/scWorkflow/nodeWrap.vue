<template>
	<promoter v-if="nodeConfig.type==0" v-model="nodeConfig"></promoter>

	<approver v-if="nodeConfig.type==1" v-model="nodeConfig"></approver>

	<send v-if="nodeConfig.type==2" v-model="nodeConfig"></send>

	<branch v-if="nodeConfig.type==4" v-model="nodeConfig">
		<template v-slot="slot">
			<node-wrap v-if="slot.node" v-model="slot.node.childNode"></node-wrap>
		</template>
	</branch>

	<subProcess v-if="nodeConfig.type==5" v-model="nodeConfig"></subprocess>

	<node-wrap v-if="nodeConfig.childNode" v-model="nodeConfig.childNode"></node-wrap>

</template>

<script>
import approver from './nodes/approver.vue'
import promoter from './nodes/promoter.vue'
import branch from './nodes/branch.vue'
import send from './nodes/send.vue'
import subProcess from './nodes/process.vue'

export default {
	props: {
		modelValue: { type: Object, default: () => {} }
	},
	components: {
		approver,
		promoter,
		branch,
		send,
		subProcess
	},
	data() {
		return {
			nodeConfig: {},
		}
	},
	watch:{
		modelValue(val){
			this.nodeConfig = val
		},
		nodeConfig(val){
			this.$emit("update:modelValue", val)
		}
	},
	mounted() {
		this.nodeConfig = this.modelValue
	},
	methods: {
	}
}
</script>

<style>
</style>
