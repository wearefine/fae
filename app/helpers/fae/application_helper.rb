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

    def fae_image_form(f, item, image_name: nil, image_label: nil, alt_label: nil, caption_label: nil, omit: nil, show_thumb: nil, required: nil, helper_text: nil, alt_helper_text: nil, caption_helper_text: nil)
      render 'fae/images/image_uploader', f: f, item: item, image_name: image_name, image_label: image_label, alt_label: alt_label, caption_label: caption_label, omit: omit, show_thumb: show_thumb, required: required, helper_text: helper_text, alt_helper_text: alt_helper_text, caption_helper_text: caption_helper_text
    end

    def fae_file_form(f, item, file_name: nil, file_label: nil, helper_text: nil, required: nil)
      render 'fae/application/file_uploader', f: f, item: item, file_name: file_name, file_label: file_label, required: required, helper_text: helper_text
    end

    def fae_content_form(f, attribute, label: nil, hint: nil, helper_text: nil)
      render 'fae/application/content_uploader', f: f, attribute: attribute, label: label, hint: hint, helper_text: helper_text
    end
  end
end
