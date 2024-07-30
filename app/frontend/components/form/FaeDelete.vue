<template>
  <button @click="handleClick">
    Delete
  </button>
</template>

<script setup lang="ts">
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  path: string
}>()

function handleClick() {
  // router.visit(props.path, { method: 'delete' })
  // router.reload()
  fetch(props.path, { method: 'delete' })
    .then(response => {
      if (response.ok) {
        // router.reload()
      } else {
        console.log('Error:', response)
      }
    })
    .catch(error => {
      console.error('Error:', error)
    }
  )
}

</script>

<style scoped>

</style>