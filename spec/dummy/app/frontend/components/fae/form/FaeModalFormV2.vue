<template>
  <div>
    <button class="bg-grey my-l p-4" @click.prevent="getForm">Add New {{ props.assoc }}</button>
    <BaseModal :show="state.showModal" @update:show="state.showModal = $event">
      <template #default="{ toggleOpen, isOpen }">
        <AssocForm 
          v-bind="state.formProps"
          v-on="{submit: () => { toggleOpen(false) }}"
          inline
          :parent-id="props.parentId"
        ></AssocForm>
      </template>
    </BaseModal>
  </div>
</template>

<script setup lang="ts">
import BaseModal from '~/components/base/BaseModal.vue'
import { reactive, ref, defineAsyncComponent } from 'vue'

const props = defineProps<{
  assoc: string
  parentId?: number
}>()

const AssocForm = defineAsyncComponent(() => {
  return new Promise((resolve, reject) => {
    const form = import(`~/pages/admin/${props.assoc}/form.vue`)
    resolve(form)
  })
})

const state = reactive({
  showModal: false,
  formProps: null as null | any,
})

async function getForm() {
  const response = await fetch(`/admin/${props.assoc}/new`, { headers: {'X-Inertia': 'true'} })
  if (!response.ok) {
    throw new Error(`Response status: ${response.status}`);
  }
  const json = await response.json()
  state.formProps = json.props
  state.showModal = true
}




</script>

<style scoped>

</style>