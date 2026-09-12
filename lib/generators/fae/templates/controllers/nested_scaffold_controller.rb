module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::NestedBaseController
    include Fae::InertiaNestedRenderable

    def self.fae_form_fields
      [
        {
          section: {
            title: 'Main',
            fields: [
<% @inertia_form_fields.each_with_index do |field, index| -%>
<% comma = index + 1 != @inertia_form_fields.length ? ',' : '' -%>
<% if field[:type] == :select -%>
              { name: :<%= field[:name] %>, type: :select, collection: <%= field[:collection] %> }<%= comma %>
<% else -%>
              { name: :<%= field[:name] %>, type: :<%= field[:type] %><%= ', slug_source: true' if field[:slug_source] %> }<%= comma %>
<% end -%>
<% end -%>
            ]
          }
        }
      ]
    end
<% if @inertia_unsupported_fields.present? %>

    # Inertia does not yet ship first-class field renderers for these
    # attachment types. Add custom blocks in #fae_form_fields when needed.
<% @inertia_unsupported_fields.each do |field| -%>
    # - <%= field[:name] %> (<%= field[:type] %>)
<% end -%>
<% end %>

<% if options.polymorphic %>
    def new
      @item = @klass.new
      raise_undefined_parent if @item.fae_nested_foreign_key.blank?
      item_id = params[:item_id].to_i || nil
      item_class = params[:item_class] || nil
      @item.send("<%= @polymorphic_name %>_id=", item_id)
      @item.send("<%= @polymorphic_name %>_type=", item_class)
      build_assets
    end
<% end %>
<% if @attachments.present? %>
    private

    def build_assets
<% @attachments.each do |attachment| -%>
<% if attachment.type == :seo_set -%>
      if @item.<%= attachment.name %>.blank?
        @item.build_<%= attachment.name %>
        @item.<%= attachment.name %>.build_social_media_image
      end
<% else -%>
      @item.build_<%= attachment.name %> if @item.<%= attachment.name %>.blank?
<% end -%>
<% end -%>
    end
<% end %>
  end
end