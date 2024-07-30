<template>
  <div class="base-input" :class="{'visited': blurred || isInvalid }">
    <label>
      <div class="label-text" :class="{ minify: focused || !!props.modelValue || attrs.type === 'date' }">
        {{ label }}
        <span v-if="required">*</span>
      </div>
      <component 
        ref="inputEl"
        :is="inputTag"
        v-bind="attrs"
        @focus="handleFocus"
        @blur="handleBlur"
        @input="handleInput"
        @invalid="handleInvalid"
        :name="name"
        :modelValue="modelValue"
        :required="required"
      />
    </label>
    <p v-if="showErrorMessage()" class="error-message">
      {{  errorMessage() }}
    </p>
  </div>
</template>

<script setup lang="ts">
import { ref, defineProps, defineEmits, useAttrs } from 'vue'
import { useValidation } from '@fae/app/frontend/composables/use-validation'

const attrs = useAttrs()

const props = defineProps({
  label: {
    type: String,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  modelValue: {
    type: String,
  },
  required: {
    type: Boolean,
    default: false,
  },
  inputTag: {
    type: String,
    default: 'input',
  },
})


const inputEl = ref<HTMLInputElement | HTMLTextAreaElement | null>(null)

const { 
  isInvalid,
  errorMessage, 
  showErrorMessage, 
  handleBlur, 
  handleFocus, 
  handleInvalid, 
  focused, 
  blurred 
} = useValidation(inputEl, { useCustomErrorMessages: true})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string): void
}>()


function handleInput(e: Event) {
  if (e.target instanceof HTMLInputElement) emit('update:modelValue', e.target?.value)
}

</script>

<style scoped lang="postcss">
.base-input {

  &:has(input:invalid).visited {
    @apply text-red;

    .label-text span {
      @apply text-red;
    }

    input {
      @apply border-b-red;
    }
  }

  input,
  textarea {
    @apply border-b-grey border-b;
    position: relative;
    width: 100%;
    background: transparent;
    padding-bottom: 10px;
    border-radius: 0;

    z-index: 1;


    &:focus {
      outline: none;
    }
  }

  label {
    position: relative;
    padding-top: 1.4em;
    display: block;
  }

  .label-text {
    position: absolute;
    top: 0;
    left: 0;

    transform: translateY(1.4em);
    transform-origin: left top;

    transition: transform 0.33s ease, font-size 0.33s ease, line-height 0.33s ease;

    &.minify {
      transform: none;
    }

    span {
      position: relative;
      left: 0em;
      top: 0em;
    }
  }

  .error-message {
    position: absolute;
  }
}
</style>
