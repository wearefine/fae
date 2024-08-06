<template>
  <FaeForm :path="path" :form="form" :edit="props.edit">

    <FaeInput  
      label="First Name" 
      name="first_name" 
      v-model="form.first_name" 
    />
    <FaeInput  
      label="Last Name" 
      name="last_name" 
      v-model="form.last_name" 
    />
    <FaeInput  
      label="Role" 
      name="role" 
      v-model="form.role" 
    />
    <FaeInput  
      label="Bio" 
      name="bio" 
      v-model="form.bio" 
    />

    <input 
      v-if="props.parent_item && props.parent_id" 
      v-model="form.team_id"
      type='hidden' 
      :name="`${props.parent_item}_id`" 
      :value="props.parent_id"
    >


  </FaeForm>
</template>



<script setup lang="ts">
import { computed, defineProps } from 'vue'

import FaeForm from '~/components/fae/form/FaeForm.vue'
import FaeInput from '~/components/fae/form/FaeInput.vue'

// import FaeForm from '@fae/app/frontend/components/form/FaeForm.vue'
// import FaeInput from '@fae/app/frontend/components/form/FaeInput.vue'

// import { useForm } from '@fae/node_modules/@inertiajs/vue3'
import { useForm } from '@inertiajs/vue3'

const props = defineProps<{
  edit?: boolean
  item: any
  index_path: string
  parent_id?: number
  parent_item?: string
}>()

const path = computed(() => {
  return props.edit ? `${props.index_path}/${props.item.id}` : props.index_path
})

const form = useForm({
  first_name: props.item.first_name,
  last_name: props.item.last_name,
  role: props.item.number,
  bio: props.item.bio,
  team_id: props.item.team_id || props.parent_id
})



</script>

<style scoped>

</style>