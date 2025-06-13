<template>
	<over v-if="nodeConfig.type==-1" v-model="nodeConfig"></over>

	<promoter v-if="nodeConfig.type==0" v-model="nodeConfig"></promoter>

	<approver v-if="nodeConfig.type==1" v-model="nodeConfig"></approver>

	<send v-if="nodeConfig.type==2" v-model="nodeConfig"></send>

	<branch v-if="nodeConfig.type==4" v-model="nodeConfig">
		<template v-slot="slot">
			<node-wrap v-if="slot.node" v-model="slot.node.childNode"></node-wrap>
		</template>
	</branch>

	<subProcess v-if="nodeConfig.type==5" v-model="nodeConfig"></subprocess>

	<delay v-if="nodeConfig.type==6" v-model="nodeConfig"></delay>

	<trigger v-if="nodeConfig.type==7" v-model="nodeConfig"></trigger>

	<trigger v-if="nodeConfig.type==8" v-model="nodeConfig"></trigger>

	<parallel v-if="nodeConfig.type==9" v-model="nodeConfig"></parallel>

	<inclusive v-if="nodeConfig.type==23" v-model="nodeConfig"></inclusive>

	<route v-if="nodeConfig.type==30" v-model="nodeConfig"></route>

	<refuse v-if="nodeConfig.type==31" v-model="nodeConfig"></refuse>

	<node-wrap v-if="nodeConfig.childNode" v-model="nodeConfig.childNode"></node-wrap>

</template>

<script>
import approver from './nodes/approver.vue'
import promoter from './nodes/promoter.vue'
import branch from './nodes/branch.vue'
import send from './nodes/send.vue'
import subProcess from './nodes/process.vue'
import over from './nodes/over.vue'
import through from './nodes/through.vue'
import refuse from './nodes/refuse.vue'
import delay from './nodes/delay.vue'
import trigger from './nodes/trigger.vue'
import parallel from './nodes/parallel.vue'
import inclusive from './nodes/inclusive.vue'
import route from './nodes/route.vue'


export default {
	props: {
		modelValue: { type: Object, default: () => {} }
	},
	components: {
		approver,
		promoter,
		branch,
		send,
		subProcess,
		over,
		through,
		refuse,
		delay,
		trigger,
		parallel,
		inclusive,
		route,
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
		nodeConfig(val) {
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
