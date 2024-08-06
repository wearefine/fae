<template>
<div class="">
  <form @submit.prevent="handleSubmit">

    <div v-if="errors">{{ errors }}</div>
    <slot></slot>

    <button type="submit" class="block border border-solid p-5 mt-10">Save</button>
  </form>
</div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  edit: boolean
  path: string,
  form: any
}>()

const emit = defineEmits<{
  (e: 'submit', value: boolean): void
}>()

const errors = ref(null)

async function handleSubmit(e: Event) {
  if (props.edit) {
    props.form.put(props.path)
  } else {

    props.form.post(props.path, { 
      onSuccess: (page) => { 
        router.reload()
        emit('submit', true)
      },
      onError: (serverErrors) => {
        errors.value = serverErrors
        emit('errored', true)
      }
    })

  }
}

</script>

<style scoped>

</style>