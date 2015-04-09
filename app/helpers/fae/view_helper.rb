module Fae
  module  ViewHelper

    def fae_date_format(datetime, timezone="US/Pacific")
      datetime.in_time_zone(timezone).strftime("%b %-d, %Y %l:%M%P %Z")
    end

    def fae_path
      Rails.application.routes.url_helpers.fae_path[1..-1]
    end

    def fae_image_form(f, image_name, label: nil, alt_label: nil, caption_label: nil, show_alt: nil, show_caption: nil, required: nil, helper_text: nil, alt_helper_text: nil, caption_helper_text: nil)
      render 'fae/images/image_uploader', f: f, image_name: image_name, label: label, alt_label: alt_label, caption_label: caption_label, show_alt: show_alt, show_caption: show_caption, required: required, helper_text: helper_text, alt_helper_text: alt_helper_text, caption_helper_text: caption_helper_text
    end

    def fae_file_form(f, file_name, label: nil, helper_text: nil, required: nil)
      render 'fae/application/file_uploader', f: f, file_name: file_name, label: label, required: required, helper_text: helper_text
    end

    def fae_content_form(f, attribute, label: nil, hint: nil, helper_text: nil, markdown: nil)
      render 'fae/application/content_uploader', f: f, attribute: attribute, label: label, hint: hint, helper_text: helper_text, markdown: markdown, markdown_options: markdown_options
    end

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
    # for backwards compatibility
    alias_method :fae_toggle, :attr_toggle

  end
end
