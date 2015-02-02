module Fae
  module ApplicationHelper

    def attr_toggle(item, column)
      active = item.send(column)
      link_class = active ? 'slider-yes-selected' : ''
      model_name = item.class.to_s.include?("Fae::") ? item.class.to_s.gsub('::','').underscore.pluralize : item.class.to_s.underscore.pluralize
      url = fae.toggle_path(model_name, item.id.to_s, column)

      link_to url, class: "slider-wrapper #{link_class}", method: :post, remote: true do
        '<div class="slider-options">
          <div class="slider-option slider-option-yes">Yes</div>
          <div class="slider-option-selector"></div>
          <div class="slider-option slider-option-no">No</div>
        </div>'.html_safe
      end
    end

    def form_header(name)
      name = name.class.name.split('::').last unless name.is_a? String
      content_tag :h1, "#{params[:action]} #{name}".titleize
    end

    def markdown_helper(headers: true, emphasis: true)
      helper = "<h3>Markdown Options</h3>
            <p>
              Link | Internal: See my [About](/about/) page for details.<br>
              Link | External: This is [an example](http://example.com/ \"Title\") inline link.<br>
              List | Bullets: add an asterick with a space before the text, eg: * this will have bullets<br>
              List | Numbered: Numbers with a period and a space before the text, eg: 1. this will be item 1
            </p>"
      helper += "<h3>Emphasis</h3>
            <p>
              Add italics with _underscores_<br>
              Add bold with double **astricks**<br>
              Add combined emphasis with **astricks and _underscores_**
            </p>" if emphasis
      helper += "<h3>Headers</h3>
            <p>
              ##### H5 text<br>
              ###### H6 text
            </p>" if headers
      helper.html_safe
    end

    def require_locals(local_array, local_assigns)
      local_array.each do |loc|
        raise "#{loc} is a required local, please define it when you render this partial" unless local_assigns[loc.to_sym].present?
      end
    end

    def col_name(item, attribute)
      # if item's attribute is an association
      if item.class.reflections.include?(attribute)
        # display associaiton's fae_display_field
        item.send(attribute).fae_display_field
      else
        # otherwise it's an attribute so display it's value
        item.send(attribute)
      end
    end

    private

    def nav_path_current?(path)
      current_page?(path) || path[1..-1].classify == params[:controller].classify
    end

  end
end
