<script setup>
import { computed } from 'vue'

const props = defineProps({
  pagination: { type: Object, required: true },
})

const emit = defineEmits(['change'])

const currentPage = computed(() => Number(props.pagination.currentPage) || 1)
const totalCount = computed(() => Number(props.pagination.totalCount) || 0)
const perPage = computed(() => Number(props.pagination.perPage) || 0)

const totalPages = computed(() => {
  if (perPage.value > 0) return Math.max(1, Math.ceil(totalCount.value / perPage.value))
  return Math.max(1, Number(props.pagination.totalPages) || 1)
})

const pageTokens = computed(() => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value

  if (total <= 7) {
    for (let page = 1; page <= total; page += 1) pages.push(page)
    return pages
  }

  pages.push(1)

  const start = Math.max(2, current - 1)
  const finish = Math.min(total - 1, current + 1)

  if (start > 2) pages.push('...left')
  for (let page = start; page <= finish; page += 1) pages.push(page)
  if (finish < total - 1) pages.push('...right')

  pages.push(total)
  return pages
})

function jump(page) {
  if (!page || page === currentPage.value) return
  emit('change', page)
}
</script>

<template>
  <nav v-if="totalPages > 1" class="fae-pagination" aria-label="Pagination">
    <button
      type="button"
      class="fae-button -secondary -sm"
      :disabled="currentPage <= 1"
      @click="jump(currentPage - 1)"
    >
      Previous
    </button>

    <div class="fae-pagination__pages">
      <template v-for="token in pageTokens" :key="token">
        <span v-if="String(token).startsWith('...')" class="fae-pagination__ellipsis">…</span>
        <button
          v-else
          type="button"
          class="fae-pagination__page"
          :class="{ '-active': token === currentPage }"
          @click="jump(token)"
        >
          {{ token }}
        </button>
      </template>
    </div>

    <span class="fae-pagination__meta">
      Page {{ currentPage }} of {{ totalPages }}
    </span>

    <button
      type="button"
      class="fae-button -secondary -sm"
      :disabled="currentPage >= totalPages"
      @click="jump(currentPage + 1)"
    >
      Next
    </button>
  </nav>
</template>
