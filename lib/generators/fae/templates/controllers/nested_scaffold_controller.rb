module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::NestedBaseController

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
      @item.build_<%= attachment.name %> if @item.<%= attachment.name %>.blank?
<% end -%>
    end
<% end %>
  end
end
