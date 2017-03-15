module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::BaseController
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
