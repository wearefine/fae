<template>
  <FaeForm :path="props.index_path" :form="form">

    <FaeInput  
      label="Name" 
      name="name" 
      v-model="form.name" 
    />

    <!-- <FaeInput  
      label="Description" 
      name="description" 
      v-model="form.description" 
    /> -->

  </FaeForm>
</template>

<script setup lang="ts">

import FaeForm from '@fae/app/frontend/components/form/FaeForm.vue'
import FaeInput from '@fae/app/frontend/components/form/FaeInput.vue'

import { useForm } from '@fae/node_modules/@inertiajs/vue3'

const props = defineProps<{
  item: any
  index_path: string
}>()

const form = useForm({
  name: '',
  description: ''
})

function handleSubmit() {

}

</script>

<style scoped>

</style>