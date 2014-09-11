module Fae
  module FormHelper

    def fae_input(f, attribute, options={})
      class_option options
      label_and_hint_for(attribute, options)

      f.input attribute, options
    end


    def fae_prefix(f, attribute, options={})
      if options[:prefix].present?
        case options[:prefix]
        when "$"
          prefix_class = "input-icon-currency"
        when "%"
          prefix_class = "input-icon-percentage"
        else
          #TODO - we can ignore the fact that their prefix isn't a valid prefix, or we can raise an error
        end
        options[:wrapper_html] = { class: prefix_class }
      end

      fae_input f, attribute, options
    end

    private

    def label_and_hint_for(attribute, options)
      options[:label] = "#{ options[:label] || attribute.to_s.titleize }<h6 class='helper_text'>#{options[:helper_text]}</h6>".html_safe if options[:helper_text].present?
      options[:hint] = options[:hint].html_safe if options[:hint].present?
    end

    def class_option options
      options[:input_html] = { class: options[:class] } if options[:class].present?
    end
  end
end
