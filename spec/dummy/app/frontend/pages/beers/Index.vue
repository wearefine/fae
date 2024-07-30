<template>
  <div class="px-10 pt-10">

    <div class="flex justify-between">
      <h1 class="text-[40px] capitalize">{{ klass_singular }} Index</h1>
      <!-- <a :href="props.new_path" class="p-5 border border-light border-solid block">Add {{ props.klass_singular }}</a> -->
      <Link :href="props.new_path" class="p-5 border border-light border-solid block">Add {{ props.klass_singular }}</Link>
    </div>
    

    <table class="mt-10">
      <thead>
        <tr>
          <th>Name</th>
          <th>Modified</th>
          <th>On Stage</th>
          <th>On Prod</th>
          <th>Delete</th>
        </tr>
      </thead>
  
      <tbody>
        <tr v-for="item in props.items">
          <td>{{ item.name }}</td>
          <td>{{ item.updated_at }}</td>
          <td>
            <FaeToggle
              :item="item"
              :item-name="klass_name" 
              attr-name="on_stage" 
            />
          </td>
          <td>
            <FaeToggle
              :item="item"
              :item-name="klass_name" 
              attr-name="on_prod" 
            />
          </td>
          <td>
            <FaeDelete :path="item.fae_delete_path" />
          </td>
        </tr>
      </tbody>
    </table>
  </div>


</template>

<script setup lang="ts">
import FaeToggle from '@fae/app/frontend/components/form/FaeToggle.vue'
import FaeDelete from '@fae/app/frontend/components/form/FaeDelete.vue'
import { Link } from '@inertiajs/vue3'

const props = defineProps<{
  items: any[]
  index_name?: string
  new_path: string
  klass_singular: string
  klass_name: string
}>()


</script>

<style scoped>



</style>