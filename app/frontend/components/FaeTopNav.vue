<script setup>
// Levels 1 and 2 of Fae's navigation structure. Level 1 is the horizontal bar;
// level 2 is a hover dropdown beneath it. Levels 3 and 4 are FaeSideNav's job.
defineProps({
  items: { type: Array, default: () => [] },
})

// Long dropdowns wrap into columns rather than running off the screen. The
// thresholds match the legacy multi_column_nav_ul_class helper.
function columnCount(children) {
  if (children.length > 30) return 4
  if (children.length > 20) return 3
  if (children.length > 10) return 2
  return 1
}
</script>

<template>
  <nav v-if="items.length" class="fae-topnav">
    <ul class="fae-topnav__list">
      <li
        v-for="item in items"
        :key="item.text"
        class="fae-topnav__item"
        :class="[item.className, { '-open': item.open }]"
      >
        <a class="fae-topnav__link" :href="item.path">{{ item.text }}</a>

        <ul
          v-if="item.children.length"
          class="fae-topnav__dropdown"
          :style="{ '--fae-topnav-columns': columnCount(item.children) }"
        >
          <li v-for="child in item.children" :key="child.text">
            <a
              class="fae-topnav__sublink"
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
