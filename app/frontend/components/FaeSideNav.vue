<script setup>
import { ref, watch } from 'vue'

// Levels 3 and 4 of Fae's navigation structure. Fae::Navigation#side_nav
// returns nothing until the current path is that deep, so this region is
// absent on shallower screens rather than empty.
const props = defineProps({
  items: { type: Array, default: () => [] },
})

// Level-3 items with children are accordions. Replaces the jQuery in
// navigation/_navigation.js; the branch containing the current page starts
// expanded, and the user can toggle any other open.
const expanded = ref(new Set())

watch(
  () => props.items,
  (items) => {
    expanded.value = new Set(
      items.filter((item) => item.open).map((item) => item.text)
    )
  },
  { immediate: true }
)

function toggle(item) {
  const next = new Set(expanded.value)
  next.has(item.text) ? next.delete(item.text) : next.add(item.text)
  expanded.value = next
}
</script>

<template>
  <nav v-if="items.length" class="fae-sidenav">
    <ul class="fae-sidenav__list">
      <li
        v-for="item in items"
        :key="item.text"
        class="fae-sidenav__item"
        :class="[item.className, { '-open': item.open }]"
      >
        <!--
          A level-3 item with children is a toggle, not a destination:
          Fae::Navigation resolves its path to '#' because the item exists
          only to group the level-4 links beneath it.
        -->
        <button
          v-if="item.children.length"
          type="button"
          class="fae-sidenav__link fae-sidenav__toggle"
          :class="{ '-expanded': expanded.has(item.text) }"
          :aria-expanded="expanded.has(item.text)"
          @click="toggle(item)"
        >
          {{ item.text }}
        </button>

        <a v-else class="fae-sidenav__link" :href="item.path">{{ item.text }}</a>

        <ul
          v-if="item.children.length"
          v-show="expanded.has(item.text)"
          class="fae-sidenav__sublist"
        >
          <li v-for="child in item.children" :key="child.text">
            <a
              class="fae-sidenav__sublink"
              :class="[child.className, { '-current': child.current }]"
              :href="child.path"
              :aria-current="child.current ? 'page' : null"
            >
              {{ child.text }}
            </a>
          </li>
        </ul>
      </li>
    </ul>
  </nav>
</template>
