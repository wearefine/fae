<script setup>
import FaeInput from './FaeInput.vue'

defineOptions({ name: 'FaeFileInput' })

defineProps({
  name: { type: String, required: true },
})
</script>

<template>
  <FaeInput :name="name" />
</template>