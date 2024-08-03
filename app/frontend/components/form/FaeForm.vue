<template>
<div class="">
  <form @submit.prevent="form.post(path)">

    <slot></slot>

    <button type="submit" class="border border-solid p-5 mt-10">Save</button>
  </form>
</div>
</template>

<script setup lang="ts">

const props = defineProps<{
  edit: boolean
  path: string,
  form: any
}>()

const emit = defineEmits<{
  (e: 'submit', value: boolean): void
}>()

function handleSubmit(e: Event) {
  emit('submit', true)
}

</script>

<style scoped>

</style>