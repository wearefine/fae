<!-- Adapted from Vuetensils Dialog component with Teleport to <body>
  -- This component shouldn't need to be changed, the project-specific implementation should probably
  -- be made in BaseModal.vue 
  -- https://raw.githubusercontent.com/AustinGil/vuetensils/production/src/components/VDialog/VDialog.vue
-->
<template>
  <span v-if="state.localShow || slots.toggle">
    <slot
      v-if="slots.toggle"
      name="toggle"
      v-bind="{
        on: {
          click: () => (state.localShow = !state.localShow),
        },
        bind: {
          type: 'button',
          role: 'button',
          'aria-haspopup': true,
          'aria-expanded': '' + state.localShow,
        } as HTMLAttributes
      }"
    />
    <Teleport to="body">
      <Transition :name="props.transition">
        <div
          v-if="state.localShow"
          :class="['base-dialog', classes.root, classes.bg, $attrs.class]"
        >
          <Transition :name="contentTransition">
            <component
              :is="tag"
              ref="content"
              :class="['base-dialog__content', classes.content]"
              role="dialog"
              aria-modal="true"
            >
              <slot
                v-bind="{
                  close: () => (state.localShow = !state.localShow),
                  isOpen: state.localShow,
                }"
              />
            </component>
          </Transition>
        </div>
      </Transition>
    </Teleport>
  </span>
</template>
<script lang="ts" setup>
import { reactive, useSlots, ref, watch, onUnmounted } from 'vue'
// import { enableBodyScroll, disableBodyScroll } from 'body-scroll-lock'
import type { HTMLAttributes, Teleport, Transition } from 'vue'

const bodyScrollOpts = {
  reserveScrollBarGap: true,
}

const emit = defineEmits(['update:modelValue', 'open', 'close'])

const props = defineProps({
  modelValue: Boolean,
  /**
   * HTML component for the dialog content.
   */
  tag: {
    type: String,
    default: 'div',
  },
  /**
   * Flag to enable/prevent the dialog from being closed.
   */
  dismissible: {
    type: Boolean,
    default: true,
  },
  /**
   * Prevents the page from being scrolled while the dialog is open.
   */
  noScroll: Boolean,
  /**
   * Transition name to apply to the dialog.
   */
  transition: {
    type: String,
    default: '',
  },

  /**
   * Transition name to apply to the background.
   */
  contentTransition: {
    type: String,
    default: '',
  },

  classes: {
    type: Object,
    default: () => ({}),
  },

  initialFocus: {
    type: Object,
  },
})

const state = reactive({
  localShow: props.modelValue,
})

const slots = useSlots()
const content = ref<HTMLElement>()

// Update internal state when model prop changes
watch(
  () => props.modelValue,
  (next) => {
    state.localShow = next
  },
  { immediate: true }
)

// Call open/close when internal state changes
watch(
  () => state.localShow,
  (next, prev) => {
    if (typeof window === 'undefined') return

    if (next && next != prev) {
      if (document.activeElement instanceof HTMLElement) {
        onOpen()
      }
    } else {
      onClose()
    }

    emit('update:modelValue', next)
  },
  { immediate: true }
)

// Tear down
onUnmounted(() => {
  onClose()
})

function onOpen() {
  window.addEventListener('click', onClick)
  window.addEventListener('keydown', onKeydown)
  // nextTick(() => {
  //   if (content.value) {
  //     if (props.noScroll && content.value.children.item(0)) {
  //       disableBodyScroll(content.value.children.item(0) as HTMLElement, bodyScrollOpts)
  //     }
  //   }
  // })
  emit('open')
}

function onClose() {
  window.removeEventListener('click', onClick)
  window.removeEventListener('keydown', onKeydown)
  // if (props.noScroll && content.value && content.value.children.item(0)) {
  //   enableBodyScroll(content.value.children.item(0) as HTMLElement)
  // }
  emit('close')
}

function onClick(event: MouseEvent) {
  if (
    event.target instanceof HTMLElement &&
    event.target.classList.contains('base-dialog') &&
    props.dismissible
  ) {
    state.localShow = false
  }
}

function onKeydown(event: KeyboardEvent) {
  if (event.key === 'Escape' && props.dismissible) {
    state.localShow = false
  }
}
</script>

<style>
.base-dialog {
  display: flex;
  align-items: center;
  justify-content: center;
  position: fixed;
  z-index: 100;
  inset: 0;
  width: 100%;
  height: 100vh;
  top: 0;
  left: 0;
}

.base-dialog__content {
  width: 100%;
}

.base-dialog__content:focus {
  outline: 0;
}
</style>
