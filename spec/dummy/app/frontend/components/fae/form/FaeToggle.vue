<template>

  <label class="switch">
    <input type="checkbox" :checked="!!props.item[props.attrName]" @change="handleChange"/>
    <span class="slider"></span>
  </label>

</template>

<script setup lang="ts">
import { computed, defineProps, onMounted, ref } from 'vue'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  item: Record<string, string>
  itemName: string
  attrName: string
}>()

// const token = ref(null)

// onMounted(() => {
//   token.value = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content')
// })


const togglePath = computed(() => {
  return `toggle/${props.itemName}/${props.item.id}/${props.attrName}`
})

async function handleChange() {
  router.post(togglePath.value)
  // router.reload()
  // console.log('toggle')

  // fetch(togglePath.value, {
  //   method: 'POST',
  //   credentials: "same-origin",
  //   headers: {
  //     "X-CSRF-Token": token.value || '',
  //     "Content-Type": "application/json"
  //   },
  // }).then(response => {
  //   if (response.ok) {
  //     console.log('ok')
  //     router.reload()
  //   } else {
  //     console.log('Error:', response)
  //   }
  // })
  // .catch(error => {
  //   console.error('Error:', error)
  // })
}

</script>

<style scoped>

.switch {
  position: relative;
  display: inline-block;
  width: 60px;
  height: 34px;

  input {
    opacity: 0;
    width: 0;
    height: 0
  }
}

.slider {
  position: absolute;
  cursor: pointer;
  border-radius: 34px;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #ccc;
  -webkit-transition: .4s;
  transition: .4s;
}

.slider:before {
  position: absolute;
  content: "";
  height: 26px;
  width: 26px;
  left: 4px;
  bottom: 4px;
  border-radius: 50%;
  background-color: white;
  -webkit-transition: .4s;
  transition: .4s;
}

input:checked + .slider {
  background-color: #2196F3;
}

input:focus + .slider {
  box-shadow: 0 0 1px #2196F3;
}

input:checked + .slider:before {
  -webkit-transform: translateX(26px);
  -ms-transform: translateX(26px);
  transform: translateX(26px);
}

</style>