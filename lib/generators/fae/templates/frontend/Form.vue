<script setup>
import FaeForm from '@fae/pages/Fae/Form.vue'
<% @inertia_form_fields.map { |field| inertia_vue_component_for(field[:type]) }.uniq.each do |component| -%>
import <%= component %> from '@fae/components/<%= component %>.vue'
<% end -%>

defineOptions({ inheritAttrs: false })
</script>

<template>
  <FaeForm v-bind="$attrs">
    <template #form>
      <section id="main" class="fae-form-section" data-fae-section="main">
        <div class="fae-panel fae-form">
<% @inertia_form_fields.each do |field| -%>
          <<%= inertia_vue_component_for(field[:type]) %> name="<%= field[:name] %>" />
<% end -%>
        </div>
      </section>
    </template>
  </FaeForm>
</template>