<template>
  <FaeForm :path="path" :form="form" :edit="props.edit">

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

    <BaseModal :show="state.showModal" @update:show="handleModalToggle($event)">
      <template #toggle="{ on, bind }">
        <button class="bg-grey my-l p-4" v-bind="bind" v-on="on">Add Player</button>
      </template>

      <template #default="{ toggleOpen, isOpen }">
        <div v-if="playerFormProps">
          <PlayersForm v-bind="playerFormProps" @submit="toggleOpen(false)"/>
        </div>
      </template>
    </BaseModal>

  </FaeForm>
</template>

<script setup lang="ts">
import { computed, defineProps, ref, watch, reactive } from 'vue'
import PlayersForm from '~/pages/admin/players/form.vue'
import BaseModal from '~/components/base/BaseModal.vue'
import FaeForm from '~/components/fae/form/FaeForm.vue'
import FaeInput from '~/components/fae/form/FaeInput.vue'

// import FaeForm from '@fae/app/frontend/components/form/FaeForm.vue'
// import FaeInput from '@fae/app/frontend/components/form/FaeInput.vue'

// import { useForm } from '@fae/node_modules/@inertiajs/vue3'
import { useForm, router } from '@inertiajs/vue3'

const state = reactive({
  showModal: false
})

const props = defineProps<{
  players: any[]
  edit?: boolean
  item: any
  index_path: string
}>()

const path = computed(() => {
  return props.edit ? `${props.index_path}/${props.item.id}` : props.index_path
})

const form = useForm({
  name: props.item.name,
  city: props.item.city,
  history: props.item.history
})

let playerFormProps = ref(null)

function handleSubmit() {
  state.showModal = false
  console.log('handle submit')
}


async function handleModalToggle(isShowing: boolean) {

  if (isShowing) {
    // router.get('/admin/players/new')
    state.showModal = true
    try {
      const response = await fetch('/admin/players/new', { headers: {'X-FAE-INLINE': 'true'}})
      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
      }
      const json = await response.json()
      playerFormProps.value = json.props
    } catch (error) {
      console.error(error.message);
    }
    
  }

}




</script>

<style scoped>

</style>