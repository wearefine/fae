<template>
<div class="px-page-padding pt-l pr-[40vw]">
  <form @submit.prevent="handleSubmit">

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
  if (props.edit) {
    props.form.put(props.path)
  } else {
    props.form.post(props.path)
  }
  // emit('submit', true)
}

</script>

<style scoped>

</style>