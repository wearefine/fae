module Fae
  module NestedFormHelper

    def th_columns(attribute)
      attribute = (attribute.is_a?(Hash) && attribute[:title]) ? attribute[:title] : attribute

      th_class = [:on_production, :on_prod, :on_stage].include?(attribute) ? 'main_table-header-live' : ''
      content_tag(:th, class: th_class) do attribute.to_s.titleize end
    end

    def td_columns(params)
      attribute = params[:col]
      attributes = params[:cols]
      item = params[:item]
      edit_path = params[:edit_path]
      edit_column = params[:edit_column]

      attribute = (attribute.is_a?(Hash) && attribute[:attr]) ? attribute[:attr] : attribute
      first_attribute = (attributes.first.kind_of?(Hash) && attributes.first[:attr]) ? attributes.first[:attr] : attributes.first

      if attribute == first_attribute && !edit_column
        content_tag(:td, class: 'main_table-description-item') do
          content_tag(:a, class: 'js-edit-link', href: self.send(edit_path, item)) do
            col_name_or_image(item, attribute)
          end
        end
      elsif item.class.columns_hash[attribute.to_s].present? && item.class.columns_hash[attribute.to_s].type == :boolean
        content_tag(:td) do attr_toggle(item, attribute) end
      else
        content_tag(:td) do col_name_or_image(item, attribute) end
      end
    end

  end
end