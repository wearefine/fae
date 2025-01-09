<template>
  <FaeForm :path="path" :form="form" :edit="props.edit">

    <FaeInput  
      label="First Name" 
      name="first_name" 
      v-model="form.player.first_name" 
    />
    <FaeInput  
      label="Last Name" 
      name="last_name" 
      v-model="form.player.last_name" 
    />
    <FaeInput  
      label="Number" 
      name="number" 
      v-model="form.player.number" 
    />
    <FaeInput  
      label="Bio" 
      name="bio" 
      v-model="form.player.bio" 
    />


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
  inline?: boolean
  edit?: boolean
  item: any
  index_path: string
  path?: string
}>()

const path = computed(() => {
  if (props.path) return props.path
  if (props.inline) return `${props.index_path}/inline-create`
  return props.edit ? `${props.index_path}/${props.item.id}` : props.index_path
})

const form = useForm({
  player: {
    first_name: props.item.first_name,
    last_name: props.item.last_name,
    number: props.item.number,
    bio: props.item.bio
  }
})



</script>

<style scoped>

</style>