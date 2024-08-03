<template>
  <Layout>
    <FaeForm :path="path" :form="form" :edit="props.edit">
  
      <FaeInput  
        label="Name" 
        name="name" 
        v-model="form.name" 
      />
  
      <!-- <FaeInput  
        label="Description" 
        name="description" 
        v-model="form.description" 
      /> -->
  
    </FaeForm>
  </Layout>
</template>

<script setup lang="ts">
import { computed, defineProps } from 'vue'
import Layout from '~/layouts/Main.vue'
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
}>()

const path = computed(() => {
  return props.edit ? `${props.index_path}/${props.item.id}` : props.index_path
})

const form = useForm({
  name: props.item.name,
  description: props.item.description
})


console.log(form)


</script>

<style scoped>

</style>