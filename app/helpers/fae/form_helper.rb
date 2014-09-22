module Fae
  module FormHelper

    def fae_input(f, attribute, options={})
      custom_options options
      label_and_hint(attribute, options)

      f.input attribute, options
    end

    def fae_association(f, attribute, options={})
      custom_options options
      label_and_hint(attribute, options)

      f.association attribute, options
    end

    def fae_prefix(f, attribute, options={})
      raise "undefined method '#{attribute}' for #{f.object}" if is_attribute_or_association?(f, attribute) == false
      raise "MissingRequiredOption: fae_prefix helper method requires the 'prefix' option." if options[:prefix].blank?
      symbol 'prefix', options[:prefix], options
      fae_input f, attribute, options
    end

    def fae_suffix(f, attribute, options={})
      raise "undefined method '#{attribute}' for #{f.object}" if is_attribute_or_association?(f, attribute) == false
      raise "MissingRequiredOption: fae_suffix helper method requires the 'suffix' option." if options[:suffix].blank?
      symbol 'suffix', options[:suffix], options
      fae_input f, attribute, options
    end


    def fae_radio(f, attribute, options={})
      options[:as] = :radio_collection

      options[:alignment] = 'radio_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'radio_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?

      options[:wrapper_class] = options[:wrapper_class].present? ? "#{options[:wrapper_class]} #{options[:alignment]}" : options[:alignment]
      association_or_input f, attribute, options
    end

    def fae_checkbox(f, attribute, options={})
      options[:as] = :check_boxes

      options[:alignment] = 'radio_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'checkbox_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?

      options[:wrapper_class] = options[:wrapper_class].present? ? "#{options[:wrapper_class]} #{options[:alignment]}" : options[:alignment]

      association_or_input f, attribute, options
    end

    def fae_pulldown(f, attribute, options={})
      raise "MissingRequiredOption: fae_pulldown requires a 'collection' when using it on an ActiveRecord attribute." if !options.has_key?(:collection) && f.object.attribute_names.include?(attribute.to_s)
      raise "ImproperOptionValue: The value #{options[:size]} is not a valid option for 'size'. Please use 'short' or 'long'." if options[:size].present? && ['short','long'].include?(options[:size]) == false

      if options[:size] == "short"
        options[:class] = options[:class].present? ? "#{options[:class]} small_pulldown" : "small_pulldown"
      end

      association_or_input f, attribute, options
    end

    def fae_multiselect(f, attribute, options={})
      raise "'#{attribute}' must be an association of #{f.object}" if !is_association?(f, attribute)
      raise "ImproperOptionValue: The value '#{options[:two_pane]}' is not a valid option for 'two_pane'. Please use a Boolean." if options[:two_pane].present? && !!options[:two_pane] != options[:two_pane]

      if options[:two_pane] == true
        options[:class] = options[:class].present? ? "#{options[:class]} multiselect" : "multiselect"
      end

      fae_association f, attribute, options
    end



    private

    def custom_options options
      options[:input_html] = { class: options[:class] } if options[:class].present?
      options[:wrapper_html] = { class: options[:wrapper_class]} if options[:wrapper_class].present?
    end

    def label_and_hint(attribute, options)
      options[:label] = "#{ options[:label] || attribute.to_s.titleize }<h6 class='helper_text'>#{options[:helper_text]}</h6>".html_safe if options[:helper_text].present?
      options[:hint] = options[:hint].html_safe if options[:hint].present?
    end

    def is_attribute_or_association?(f, attribute)
      f.object.respond_to?(attribute)
    end

    def is_association?(f, attribute)
      is_attribute_or_association?(f, attribute) && !f.object.attribute_names.include?(attribute.to_s)
    end

    def association_or_input(f, attribute, options)
      if is_attribute_or_association?(f, attribute)
        f.object.attribute_names.include?(attribute.to_s) ? fae_input(f, attribute, options) : fae_association(f, attribute, options)
      end
    end

    def symbol(type, val, options)
      options[:as] = :symbol
      options[:wrapper_class] = options[:wrapper_class].present? ? "#{options[:wrapper_class]} input symbol--#{type}" : "input symbol--#{type}"
      options[:span_class]  = "input-symbol--#{type}"
      options[:span_class] += " icon-#{val}" if options[:icon].present?

      options[:content_text] = val if options[:icon].blank?
    end
  end
end
