module Fae
  module  ViewHelper

    def fae_date_format(datetime, timezone="US/Pacific")
      datetime.in_time_zone(timezone).strftime("%b %-d, %Y%l:%M%P %Z")
    end

    def fae_path
      Rails.application.routes.url_helpers.fae_path[1..-1]
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