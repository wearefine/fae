<script setup>
import FaeAuthForm from '../../../components/FaeAuthForm.vue'
import { authFormProps } from '../../../components/authFormProps.js'
import FaeAuthLayout from '../../../layouts/FaeAuthLayout.vue'

defineOptions({ layout: FaeAuthLayout, inheritAttrs: false })

const props = defineProps(authFormProps)
</script>

<template>
  <FaeAuthForm v-bind="props" />
</template>
