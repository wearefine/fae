<template>
  <div>
    <h1>Test</h1>
    <ul>
      <li v-for="item in props.items" :key="item.id">{{ item.name }}</li>
    </ul>
  </div>
</template>

<script setup lang="ts">

const props = defineProps<{
  items: any
}>()
console.log(props.items)
</script>

<style scoped>

</style>