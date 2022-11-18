module <%= options.namespace.capitalize %>
  class <%= class_name.pluralize %>Controller < Fae::BaseController
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
