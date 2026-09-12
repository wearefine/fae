<script setup>
import FaeInput from './FaeInput.vue'

defineOptions({ name: 'FaeCtaInput' })
defineProps({ name: { type: String, required: true } })
</script>

<template>
  <FaeInput :name="name" />
</template>