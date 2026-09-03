<script setup>
import FaeForm from '@fae/pages/Fae/Form.vue'
import FaeFormFlexComponentsTable from '@fae/components/FaeFormFlexComponentsTable.vue'
import FaeFormNestedTable from '@fae/components/FaeFormNestedTable.vue'
import FaeInput from '@fae/components/FaeInput.vue'

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="main" class="fae-form-section" data-fae-section="main">
        <div class="fae-panel fae-form">
          <FaeInput name="name" />
          <FaeInput name="name_zh" />
          <FaeInput name="name_frca" />
        </div>
      </section>

      <section id="article_subcategories" class="fae-form-section" data-fae-section="article_subcategories">
        <FaeFormNestedTable association="article_subcategories" />
      </section>

      <section id="flex_components" class="fae-form-section" data-fae-section="flex_components">
        <FaeFormFlexComponentsTable />
      </section>
    </template>
  </FaeForm>
</template>