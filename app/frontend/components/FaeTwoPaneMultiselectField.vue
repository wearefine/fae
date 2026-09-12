<script setup>
import { computed, ref, watch } from 'vue'

const props = defineProps({
  id: { type: String, required: true },
  modelValue: { type: Array, default: () => [] },
  options: { type: Array, default: () => [] },
})

const emit = defineEmits(['update:modelValue'])
const availableSelection = ref([])
const chosenSelection = ref([])

const selectedValues = computed(() => props.modelValue.map(String))
const available = computed(() => props.options.filter((option) => !selectedValues.value.includes(String(option.value))))
const chosen = computed(() => selectedValues.value.map((value) =>
  props.options.find((option) => String(option.value) === value)
).filter(Boolean))

watch(() => props.modelValue, () => {
  availableSelection.value = []
  chosenSelection.value = []
})

function addSelected() {
  emit('update:modelValue', [...selectedValues.value, ...availableSelection.value])
}

function removeSelected() {
  const removed = new Set(chosenSelection.value.map(String))
  emit('update:modelValue', selectedValues.value.filter((value) => !removed.has(value)))
}
</script>

<template>
  <div class="fae-two-pane">
    <div class="fae-two-pane__pane">
      <label class="fae-two-pane__label" :for="`${id}-available`">Available</label>
      <select
        :id="`${id}-available`"
        v-model="availableSelection"
        class="fae-field__control fae-two-pane__select"
        multiple
        @dblclick="addSelected"
      >
        <option v-for="option in available" :key="option.value" :value="String(option.value)">
          {{ option.label }}
        </option>
      </select>
    </div>

    <div class="fae-two-pane__actions">
      <button type="button" class="fae-button -secondary -sm" :disabled="!availableSelection.length" @click="addSelected">
        Add →
      </button>
      <button type="button" class="fae-button -secondary -sm" :disabled="!chosenSelection.length" @click="removeSelected">
        ← Remove
      </button>
    </div>

    <div class="fae-two-pane__pane">
      <label class="fae-two-pane__label" :for="`${id}-chosen`">Selected</label>
      <select
        :id="`${id}-chosen`"
        v-model="chosenSelection"
        class="fae-field__control fae-two-pane__select"
        multiple
        @dblclick="removeSelected"
      >
        <option v-for="option in chosen" :key="option.value" :value="String(option.value)">
          {{ option.label }}
        </option>
      </select>
    </div>
  </div>
</template>