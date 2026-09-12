<script setup>
import FaeInput from './FaeInput.vue'

defineOptions({ name: 'FaeTwoPaneMultiselect' })
defineProps({ name: { type: String, required: true } })
</script>

<template>
  <FaeInput :name="name" />
</template>