<template>
  <Layout>

    <div>
  
      <div class="flex justify-between">
        <h1 class="text-[40px] capitalize">{{ klass_singular }} Index</h1>
        <Link :href="props.new_path" class="p-5 border border-light border-solid block">Add {{ props.klass_singular }}</Link>
      </div>
      
  
      <table class="mt-10 w-full">
        <thead>
          <tr class="[&>th]:text-left">
            <th>Team</th>
            <th>City</th>
            <th>History</th>
            <th>Modified</th>
            <th>On Stage</th>
            <th>On Prod</th>
            <th>Delete</th>
          </tr>
        </thead>
    
        <tbody>
          <tr v-for="item in props.items" :key='item.id'>
            <td>
              <Link :href="`${index_path}/${item.id}/edit`">{{ item.name }}</Link>
            </td>
            <td>{{ item.city }}</td>
            <td>{{ item.history }}</td>
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
  </Layout>

</template>

<script setup lang="ts">
import { Link } from "@inertiajs/vue3"
import Layout from '~/layouts/Main.vue'
import FaeToggle from '~/components/fae/form/FaeToggle.vue'
import FaeDelete from '~/components/fae/form/FaeDelete.vue'
// import FaeToggle from '@fae/app/frontend/components/form/FaeToggle.vue'
// import FaeDelete from '@fae/app/frontend/components/form/FaeDelete.vue'
// import { Link } from '@fae/node_modules/@inertiajs/vue3'

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