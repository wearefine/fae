<template>
  <button @click="handleClick">
    Delete
  </button>
</template>

<script setup lang="ts">
import { router } from '@inertiajs/vue3'
import { defineProps, onMounted, ref } from 'vue'

const props = defineProps<{
  path: string
}>()

// const token = ref(null)

// onMounted(() => {
//   token.value = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
// })


function handleClick() {
  router.visit(props.path, { method: 'delete' })
  // router.reload()

  // fetch(props.path, {
  //   method: 'DELETE',
  //   credentials: "same-origin",
  //   headers: {
  //     "X-CSRF-Token": token.value || '',
  //     "Content-Type": "application/json"
  //   },
  // }).then(response => {
  //   if (response.ok) {
  //     console.log('ok')
  //     router.reload()
  //   } else {
  //     console.log('Error:', response)
  //   }
  // })
  // .catch(error => {
  //   console.error('Error:', error)
  // })
}

</script>

<style scoped>

</style>