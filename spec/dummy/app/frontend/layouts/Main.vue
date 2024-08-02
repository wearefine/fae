<template>
  <div>

    <nav class="bg-black text-white py-10 px-5">
      <ul class="flex gap-10">
        <li v-for="item in navItems" :key="item.name">
          <Link :href="item.link">{{ item.name }}</Link>
        </li>
      </ul>
    </nav>
    <slot></slot>

  </div>
</template>

<script setup lang="ts">
import { Link } from '@inertiajs/vue3';

const navItems = [
  { name: 'Beers', link: '/admin/beers'},
  { name: 'Cats', link: '/admin/cats'},
]

</script>

<style scoped>

</style>