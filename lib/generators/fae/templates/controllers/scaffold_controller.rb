module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::<%= options.static_page ? 'SingletonPagesController' : 'BaseController' %>
    include Fae::InertiaRenderable

<% unless options.static_page %>
    def index
      render_fae_index(
        @klass.for_fae_index,
        columns: index_columns,
        inertia_links: true
      )
    end
<% end %>

    def edit
      build_assets
<% if options.static_page %>
      render_fae_form(
        @item,
        fields: self.class.fae_form_fields,
        title: "Edit #{@klass_humanized}",
        index_path: @index_path,
        submit_path: @submit_path,
        submit_method: 'patch',
        delete_path: nil,
        page: '<%= @inertia_form_page %>'
      )
<% else %>
      render_fae_form(
        fields: self.class.fae_form_fields,
        page: '<%= @inertia_form_page %>'
      )
<% end %>
    end

<% if options.static_page %>
    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        redirect_to @index_path,
                    inertia: { errors: fae_inertia_errors(@item) },
                    flash: { alert: t('fae.save_error') }
      end
    end
<% end %>

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
    # attachment types. Add custom blocks in #edit when needed.
<% @inertia_unsupported_fields.each do |field| -%>
    # - <%= field[:name] %> (<%= field[:type] %>)
<% end -%>
<% end %>

    private

<% unless options.static_page %>
    def index_columns
      {
<% @inertia_index_columns.each_with_index do |column, index| -%>
        <%= column[:key].inspect %> => '<%= column[:label] %>'<%= index + 1 != @inertia_index_columns.length ? ',' : '' %>
<% end -%>
      }
    end
<% end %>
<% if @attachments.present? %>
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
