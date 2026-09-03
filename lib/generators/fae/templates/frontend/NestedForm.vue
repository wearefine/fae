<script setup>
<% @inertia_form_fields.map { |field| inertia_vue_component_for(field[:type]) }.uniq.each do |component| -%>
import <%= component %> from '@fae/components/<%= component %>.vue'
<% end -%>
</script>

<template>
<% @inertia_form_fields.each do |field| -%>
  <<%= inertia_vue_component_for(field[:type]) %> name="<%= field[:name] %>" />
<% end -%>
</template>