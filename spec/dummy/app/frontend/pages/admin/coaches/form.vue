<template>
  <FaeForm :path="path" :form="form" :edit="props.edit">

    <FaeInput  
      label="First Name" 
      name="coach[first_name]" 
      v-model="form.coach.first_name" 
    />
    <FaeInput  
      label="Last Name" 
      name="coach[last_name]" 
      v-model="form.coach.last_name" 
    />
    <FaeInput  
      label="Role" 
      name="coach[role]" 
      v-model="form.coach.role" 
    />
    <FaeInput  
      label="Bio" 
      name="coach[bio]" 
      v-model="form.coach.bio" 
    />

    <input 
      v-if="props.parent_item && props.parent_id" 
      v-model="form.coach.team_id"
      type='hidden' 
      :name="`${props.parent_item}_id`" 
      :value="props.parent_id"
    >

    <img v-if="imageUrl" :src="imageUrl" alt="image" />
    <input 
      type="file"
      @input="handleImageInput($event)"
    />


  </FaeForm>
</template>



<script setup lang="ts">
import { computed, defineProps, watch, ref, onMounted } from 'vue'

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
  coach: {
    first_name: props.item.first_name,
    last_name: props.item.last_name,
    role: props.item.number,
    bio: props.item.bio,
    image_attributes: props.item.image,
    team_id: props.item.team_id || props.parent_id
  }
})

const imageUrl = ref('')

function handleImageInput(e: Event) {
  const target= e.target as HTMLInputElement;

  form.coach.image_attributes = {
    attached_as: 'image',
    imageable_type: 'Coach',
    asset: target.files && target.files[0]
  }
  // form.coach.image = target.files && target.files[0]
  imageUrl.value = URL.createObjectURL(form.coach.image_attributes.asset);
}


onMounted(() => {
  if (props.item.image) {
    imageUrl.value = props.item.image.asset.url
  }
})


</script>

<style scoped>

</style>