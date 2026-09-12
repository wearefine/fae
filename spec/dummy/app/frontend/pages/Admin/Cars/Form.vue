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
          <FaeInput name="car_category_id" />
          <FaeInput name="name_en" />
          <FaeInput name="name_frca" />
          <FaeInput name="name_zh" />
          <FaeImageInput name="image_en" />
          <FaeImageInput name="image_frca" />
          <FaeImageInput name="image_zh" />
        </div>
      </section>
    </template>
  </FaeForm>
</template>