module Fae
  module FormHelper

    def fae_input(f, attribute, options={})
      custom_options options
      label_and_hint(attribute, options)

      f.input attribute, options
    end



    def fae_prefix(f, attribute, text,  options={})
      symbol 'prefix', text, options
      fae_input f, attribute, options
    end

    def fae_suffix(f, attribute, text, options={})
      symbol 'suffix', text, options
      fae_input f, attribute, options
    end

    private

    def label_and_hint(attribute, options)
      options[:label] = "#{ options[:label] || attribute.to_s.titleize }<h6 class='helper_text'>#{options[:helper_text]}</h6>".html_safe if options[:helper_text].present?
      options[:hint] = options[:hint].html_safe if options[:hint].present?
    end

    def custom_options options
      options[:input_html] = { class: options[:class] } if options[:class].present?
    end

    def symbol(type, val, options)
      options[:as] = :symbol
      options[:span_class]  = "input-symbol--#{type}"
      options[:span_class] += " icon-#{val}" if options[:icon].present?

      options[:content_text] = val if options[:icon].blank?
    end
  end
end
