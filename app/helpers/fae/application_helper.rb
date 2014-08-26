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
      url = toggle_path(model_name, item.id.to_s, column)

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

  end
end
