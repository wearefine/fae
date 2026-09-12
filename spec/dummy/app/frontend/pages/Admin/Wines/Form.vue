<script setup>
import FaeCtaInput from '@fae/components/FaeCtaInput.vue'
import FaeFileInput from '@fae/components/FaeFileInput.vue'
import FaeForm from '@fae/pages/Fae/Form.vue'
import FaeFormFlexComponentsTable from '@fae/components/FaeFormFlexComponentsTable.vue'
import FaeFormNestedTable from '@fae/components/FaeFormNestedTable.vue'
import FaeImageInput from '@fae/components/FaeImageInput.vue'
import FaeInput from '@fae/components/FaeInput.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="content" class="fae-form-section" data-fae-section="content">
        <div class="fae-panel fae-form">
          <FaeInput name="name_en" />
          <FaeInput name="name_zh" />
          <FaeInput name="name_frca" />
          <FaeInput name="description_en" />
          <FaeInput name="description_zh" />
          <FaeInput name="description_frca" />
          <FaeInput name="food_pairing_en" />
          <FaeInput name="food_pairing_zh" />
          <FaeInput name="food_pairing_ja" />
        </div>
      </section>

      <section id="oregon_winemakers" class="fae-form-section" data-fae-section="oregon_winemakers">
        <FaeFormNestedTable association="oregon_winemakers" />
      </section>

      <section id="california_winemakers" class="fae-form-section" data-fae-section="california_winemakers">
        <FaeFormNestedTable association="california_winemakers" />
      </section>

      <section id="calls_to_action" class="fae-form-section" data-fae-section="calls_to_action">
        <div class="fae-panel fae-form">
          <FaeCtaInput name="test_cta_en" />
          <FaeCtaInput name="test_cta_zh" />
          <FaeCtaInput name="test_cta_ja" />
        </div>
      </section>

      <section id="associations" class="fae-form-section" data-fae-section="associations">
        <div class="fae-panel fae-form">
          <FaeInput name="release_ids" />
        </div>
      </section>

      <section id="components" class="fae-form-section" data-fae-section="components">
        <FaeFormFlexComponentsTable />
      </section>

      <section id="assets" class="fae-form-section" data-fae-section="assets">
        <div class="fae-panel fae-form">
          <FaeImageInput name="image_en" />
          <FaeImageInput name="image_frca" />
          <FaeFileInput name="pdf_en" />
          <FaeFileInput name="pdf_frca" />
        </div>
      </section>
    </template>
  </FaeForm>
</template>