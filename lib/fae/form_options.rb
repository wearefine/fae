module Fae
  class FormOptions
    include ActionView::Helpers::TagHelper
    attr_accessor :output_buffer

    def initialize(attribute, text_options, markdown_options, input_options)
      @attribute = attribute
      @required = text_options[:required]
      @label = text_options[:label]
      @hint = text_options[:hint]
      @helper_text = text_options[:helper_text]
      @markdown = markdown_options[:markdown]
      @markdown_supported = markdown_options[:markdown_supported]
      @input_options = input_options
    end

    def to_hash
      {
        label: set_label,
        hint: @hint,
        input_html: set_input_html,
        wrapper_html: @input_options.fetch(:wrapper_html, {})
      }
    end

    private

    def set_label
      return false if label_blank?
      generate_label.html_safe
    end

    def label_blank?
      @label == '' || @label == false
    end

    def generate_label
      attribute_label = @attribute.to_s.titleize
      label = @required ? "<abbr title='required'>*</abbr> #{attribute_label}" : attribute_label

      label + content_tag(:h6, class: 'helper_text') do
        @helper_text ||= attempt_common_helper_text
        helper_text = content_tag(:span, @helper_text)
        markdown_supported = content_tag(:span, 'Markdown Supported', class: 'markdown-support') if @markdown_supported.present?
        "#{helper_text} #{markdown_supported}".html_safe
      end
    end

    def set_input_html
      input_html = @input_options.fetch(:input_html, {})
      return input_html unless @markdown

      @input_options[:input_html] = { class: "#{input_html[:class]} js-markdown-editor" }
      @input_options[:input_html]
    end

    def attempt_common_helper_text
      case @attribute
      when :seo_title
        'Company Name | Keyword-driven description of the page section. Approx 65 characters.'
      when :seo_description
        'Displayed in search engine results. Under 150 characters.'
      else
        ''
      end
    end
  end
end
