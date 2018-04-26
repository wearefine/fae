module Fae
  module NestedFormHelper

    def th_columns(attribute)
      if (attribute.is_a?(Hash) && attribute[:title])
        attribute = attribute[:title]
        attribute_title = attribute
      else
        attribute = :modified if ['updated_at', 'modified_at'].include? attribute.to_s
        attribute_title = attribute.to_s.titleize
      end

      th_class = '-action-wide' if [:on_production, :on_prod, :on_stage, :updated_at, :created_at, :modified].include?(attribute)
      content_tag(:th, class: th_class) do attribute_title end
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
        content_tag(:td, fae_toggle(item, attribute))
      else
        content_tag(:td, col_name_or_image(item, attribute))
      end
    end

  end
end