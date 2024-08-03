<template>
  <div>
    <ul>
      <li v-for="item in props.items" :key='item.id'>
        <Link :href="`${index_path}/${item.id}/edit`">{{ item.name }}</Link>
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  items: any[]
  index_name?: string
  new_path: string
  klass_singular: string
  klass_name: string
  index_path: string
}>()

</script>

<style scoped>

</style>