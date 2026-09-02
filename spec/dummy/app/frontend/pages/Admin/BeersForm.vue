<script setup>
import FaeForm from '@fae/pages/Fae/Form.vue'
import FaeFormNestedTable from '@fae/components/FaeFormNestedTable.vue'
import FaeImageInput from '@fae/components/FaeImageInput.vue'
import FaeInput from '@fae/components/FaeInput.vue'
import FaeRankedSelect from '@fae/components/FaeRankedSelect.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="main" class="fae-form-section" data-fae-section="main">
        <div class="fae-panel fae-form">
          <FaeInput name="on_stage" />
          <FaeInput name="on_prod" />
          <FaeInput name="name" />
          <FaeImageInput name="image" />
          <FaeRankedSelect name="aroma_ids" />
        </div>
      </section>

      <section id="poly_things" class="fae-form-section" data-fae-section="poly_things">
        <FaeFormNestedTable association="poly_things" />
      </section>
    </template>
  </FaeForm>
</template>