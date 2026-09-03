<script setup>
import FaeIndex from '@fae/pages/Fae/Index.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeIndex v-bind="$attrs" />
</template>