<script setup>
import FaeForm from '@fae/pages/Fae/Form.vue'
import FaeImageInput from '@fae/components/FaeImageInput.vue'
import FaeInput from '@fae/components/FaeInput.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="main" class="fae-form-section" data-fae-section="main">
        <div class="fae-panel fae-form">
          <FaeInput name="name" />
          <FaeInput name="slug" />
          <FaeImageInput name="image" />
        </div>
      </section>
    </template>
  </FaeForm>
</template>