<template>
  <form @submit.prevent="form.post('/admin/cats')">

    <label>
      Name
      <input type="text" v-model="form.name">
    </label>
    <label>
      Description
      <input type="text" v-model="form.description">
    </label>

    <button type="submit">Submit</button>
  </form>
</template>

<script setup lang="ts">

import { useForm } from '@inertiajs/vue3'

const props = defineProps<{
  cat: any
}>()

const form = useForm({
  name: '',
  description: ''
})

</script>

<style scoped>

</style>