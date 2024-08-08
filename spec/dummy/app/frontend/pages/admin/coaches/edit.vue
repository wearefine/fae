<template>
  <Layout>
    <EditForm v-bind="props" edit  class="pr-[40vw]"/>
  </Layout>
</template>

<script setup lang="ts">
import Layout from '~/layouts/Main.vue'
import EditForm from './form.vue'

const props = defineProps<{
  item: any
  players: any[]
  index_name?: string
  new_path: string
  klass_singular: string
  klass_name: string
  index_path: string
}>()

</script>

<style scoped>

</style>