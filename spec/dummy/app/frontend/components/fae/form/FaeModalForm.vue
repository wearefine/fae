<template>
  <BaseModal @update:show="getForm($event)">
    <template #toggle="{ on, bind }">
      <button class="bg-grey my-l p-4" v-bind="bind" v-on="on">Add {{ name }}</button>
    </template>

    <template #default="{ toggleOpen, isOpen }">
      <div v-if="formProps">
        <p>New {{ name }} </p>
        <slot v-bind="{ formProps: formProps, on: { submit: () => { toggleOpen(false) }, errored: () => { return }}}"></slot>
      </div>
    </template>
  </BaseModal>
</template>

<script setup lang="ts">
import BaseModal from '~/components/base/BaseModal.vue'
import { reactive, ref } from 'vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  name: string
  path: string
}>()

const formProps = ref(null)

async function getForm(isShowing: boolean) {

  if (isShowing) {
    try {
      const response = await fetch(props.path, { headers: {'X-Inertia': 'true', 'X-FAE-INLINE': 'true'} })
      if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
      }
      const json = await response.json()
      formProps.value = json.props
    } catch (error) {
      console.error(error.message);
    }
    
  }

}


</script>

<style scoped>

</style>