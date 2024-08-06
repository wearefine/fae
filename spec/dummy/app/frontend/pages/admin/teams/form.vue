<template>
  <FaeForm :path="path" :form="form" :edit="props.edit">

    <template #default="{ errors }">

      <FaeInput  
        label="Name" 
        name="name" 
        v-model="form.name" 
      />
      <FaeInput  
        label="City" 
        name="city" 
        v-model="form.city" 
      />
      <FaeInput  
        label="History" 
        name="history" 
        v-model="form.history" 
      />
  
      <label class="mt-s inline-block mr-m">
        Players:
        <select>
          <option v-for="player in players"> {{ player.first_name }} {{ player.last_name }}</option>
        </select>
      </label>
  
      <FaeModalForm name="player" path="/admin/players/new">
        <template #default="{ formProps, on }">
          <PlayersForm v-bind="formProps" v-on="on" path="/admin/players/inline-create" />
        </template>
      </FaeModalForm>
  
      
      <div>
        <FaeModalForm name="coach" path="/admin/coaches/new">
          <template #default="{ formProps, on }">
            <CoachForm 
              v-bind="formProps" 
              v-on="on" 
              :parent_item="props.klass_singular"  
              :parent_id="props.item.id"
              path="/admin/coaches/inline-create"
            />
          </template>
        </FaeModalForm>
        <ul v-if="item.coaches && item.coaches.length > 0">
          <li v-for="coach in item.coaches" :key="coach.id">
            {{ coach.first_name }}
          </li>
        </ul>
        <p v-else>No Coaches Yet</p>
        <p>{{ item }}</p>
      </div>
      
    </template>


  </FaeForm>
</template>

<script setup lang="ts">
import { computed, defineProps, ref, watch, reactive } from 'vue'
import FaeModalForm from '~/components/fae/form/FaeModalForm.vue'
import PlayersForm from '~/pages/admin/players/form.vue'
import CoachForm from '~/pages/admin/coaches/form.vue'
import BaseModal from '~/components/base/BaseModal.vue'
import FaeForm from '~/components/fae/form/FaeForm.vue'
import FaeInput from '~/components/fae/form/FaeInput.vue'

// import FaeForm from '@fae/app/frontend/components/form/FaeForm.vue'
// import FaeInput from '@fae/app/frontend/components/form/FaeInput.vue'

// import { useForm } from '@fae/node_modules/@inertiajs/vue3'
import { useForm } from '@inertiajs/vue3'

const props = defineProps<{
  players: any[]
  edit?: boolean
  item: any
  klass_name: string
  index_path: string
  klass_singular: string
}>()

const path = computed(() => {
  return props.edit ? `${props.index_path}/${props.item.id}` : props.index_path
})

const form = useForm({
  name: props.item.name,
  city: props.item.city,
  history: props.item.history
})







</script>

<style scoped>

</style>