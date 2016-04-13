module Fae
  module NestedFormHelper

    def th_columns(attribute)
      attribute = (attribute.is_a?(Hash) && attribute[:title]) ? attribute[:title] : attribute

      th_class = '-action-wide' if [:on_production, :on_prod, :on_stage].include?(attribute)
      content_tag(:th, class: th_class) do attribute.to_s.titleize end
    end

    def td_columns(params)
      attribute = params[:col]
      attributes = params[:cols]
      item = params[:item]

      attribute = (attribute.is_a?(Hash) && attribute[:attr]) ? attribute[:attr] : attribute
      first_attribute = (attributes.first.kind_of?(Hash) && attributes.first[:attr]) ? attributes.first[:attr] : attributes.first

      if attribute == first_attribute && !params[:edit_column]
        content_tag(:td) do
          content_tag(:a, class: 'js-edit-link', href: self.send(params[:edit_path], item)) do
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