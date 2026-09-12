<script setup>
import FaeFileInput from '@fae/components/FaeFileInput.vue'
import FaeForm from '@fae/pages/Fae/Form.vue'
import FaeGroupedSelect from '@fae/components/FaeGroupedSelect.vue'
import FaeImageInput from '@fae/components/FaeImageInput.vue'
import FaeInput from '@fae/components/FaeInput.vue'
import FaeRecentChanges from '@fae/components/FaeRecentChanges.vue'
import FaeTwoPaneMultiselect from '@fae/components/FaeTwoPaneMultiselect.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="attributes" class="fae-form-section" data-fae-section="attributes">
        <div class="fae-panel fae-form">
          <FaeInput name="name" />
          <FaeInput name="vintage" />
          <FaeInput name="slug" />
          <FaeInput name="is_something" />
          <FaeInput name="seo_title" />
          <FaeInput name="seo_description" />
          <FaeInput name="intro" />
          <FaeInput name="body" />
          <FaeInput name="description" />
          <FaeInput name="content" />
          <FaeInput name="price" />
          <FaeInput name="weight" />
          <FaeInput name="video_url" />
          <FaeInput name="featured" />
          <FaeInput name="on_stage" />
          <FaeInput name="on_prod" />
          <FaeInput name="release_date" />
          <FaeInput name="show" />
          <FaeInput name="hide" />
          <FaeInput name="color" />
        </div>
      </section>

      <section id="assets" class="fae-form-section" data-fae-section="assets">
        <div class="fae-panel fae-form">
          <FaeImageInput name="bottle_shot" />
          <FaeImageInput name="hero_image" />
          <FaeFileInput name="label_pdf" />
        </div>
      </section>

      <section id="associations" class="fae-form-section" data-fae-section="associations">
        <div class="fae-panel fae-form">
          <FaeInput name="varietal_id" />
          <FaeGroupedSelect name="wine_id" />
          <FaeInput name="acclaim_ids" />
          <FaeTwoPaneMultiselect name="selling_point_ids" />
          <FaeInput name="event_ids" />
        </div>
      </section>

      <FaeRecentChanges />
    </template>
  </FaeForm>
</template>