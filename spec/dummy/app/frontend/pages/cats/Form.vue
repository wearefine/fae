<template>
  <BaseForm>
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
  </BaseForm>
</template>

<script setup lang="ts">
// @ts-ignore
import BaseForm from '@fae/app/frontend/components/BaseForm.vue'
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