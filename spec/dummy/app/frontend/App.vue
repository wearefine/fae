<template>
  <div>
    <HelloWorld class="strange" msg="Hello World from host app"/>
    <CatForm></CatForm>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import HelloWorld from './components/HelloWorld.vue'
import CatForm from '@fae/app/frontend/components/CatForm.vue'

export default defineComponent({
  name: 'App',
  components: {
    HelloWorld,
    CatForm
  },
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
}
</style>

