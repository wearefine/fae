module Fae
  module ApplicationHelper

    def amenity_select(amenity_category_id, selected_ids)
      amenities = Amenity.where(amenity_category_id: amenity_category_id)
      select_tag "amenity_id", options_for_select(amenities.map{|a| [a.name, a.id] }, disabled: selected_ids), id: "amenities_#{amenity_category_id}", prompt: "Select an amenity"
    end

    def attr_toggle(item, column)
      active = item.send(column)
      link_class = active ? 'slider-yes-selected' : ''
      model_name = item.class.to_s.underscore.pluralize
      url = fae.toggle_path(model_name, item.id.to_s, column)

      link_to url, class: "slider-wrapper #{link_class}", method: :post, remote: true do
        '<div class="slider-options">
          <div class="slider-option slider-option-yes">Yes</div>
          <div class="slider-option-selector"></div>
          <div class="slider-option slider-option-no">No</div>
        </div>'.html_safe
      end
    end

    def form_header(item)
      content_tag :h1, "#{params[:action]} #{item.class.name.split('::').last}".titleize
    end

    def image_url_with_failover(image, version)
      return image.asset.mobile.url if version === 'mobile' && image.has_mobile
      return image.asset.tablet.url if image.has_tablet
      return image.asset.url
    end

    def markdown_helper
      "<h3>Markdown Options</h3><br>
            Link | Internal: See my [About](/about/) page for details.<br>
            Link | External: This is [an example](http://example.com/ \"Title\") inline link.<br>
            List | Bullets: add an asterick with a space before the text, eg: * this will have bullets<br>
            List | Numbered: Numbers with a period and a space before the text, eg: 1. this will be item 1".html_safe
    end

    def require_locals(local_array, local_assigns)
      local_array.each do |loc|
        raise "#{loc} is a required local, please define it when you render this partial" unless local_assigns[loc.to_sym].present?
      end
    end

    def load_nested_image_form(f, item, image_name: nil, image_label: nil, alt_label: nil, omit: nil, show_thumb: nil)
      render 'fae/images/nested_image', f: f, item: item, image_name: image_name, image_label: image_label, alt_label: alt_label, omit: omit, show_thumb: show_thumb
    end

  end
end
