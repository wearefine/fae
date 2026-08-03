<script setup>
import FaeAuthForm from '../../../components/FaeAuthForm.vue'
import { authFormProps } from '../../../components/authFormProps.js'
import FaeAuthLayout from '../../../layouts/FaeAuthLayout.vue'

// Signed-out screens get the centred login card, not the admin shell.
defineOptions({ layout: FaeAuthLayout, inheritAttrs: false })

const props = defineProps(authFormProps)
</script>

<template>
  <FaeAuthForm v-bind="props" />
</template>
