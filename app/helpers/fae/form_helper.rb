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
      options[:alignment] = 'radio_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'radio_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?

      options.update(as: :radio_collection, wrapper_class: "#{options[:wrapper_class]} #{options[:alignment]}")
      association_or_input f, attribute, options
    end

    def fae_checkbox(f, attribute, options={})
      options[:alignment] = 'checkbox_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'checkbox_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?

      options.update(as: :check_boxes, wrapper_class: "#{options[:wrapper_class]} #{options[:alignment]}")

      association_or_input f, attribute, options
    end

    def fae_pulldown(f, attribute, options={})
      raise "MissingRequiredOption: fae_pulldown requires a 'collection' when using it on an ActiveRecord attribute." if !options.has_key?(:collection) && f.object.attribute_names.include?(attribute.to_s)
      raise "ImproperOptionValue: The value #{options[:size]} is not a valid option for 'size'. Please use 'short' or 'long'." if options[:size].present? && ['short','long'].include?(options[:size]) == false
      raise "ImproperOptionValue: The value #{options[:search]} is not a valid options for 'search'. Please use a Boolean." if options[:search].present? && !!options[:search] != options[:search]

      options.update(input_class: "#{options[:input_class]} small_pulldown") if options[:size] == "short"
      options.update(wrapper_class: "#{options[:wrapper_class]} select-no_search") if options[:search] == false

      association_or_input f, attribute, options
    end

    def fae_multiselect(f, attribute, options={})
      raise "'#{attribute}' must be an association of #{f.object}" if !is_association?(f, attribute)
      raise "ImproperOptionValue: The value '#{options[:two_pane]}' is not a valid option for 'two_pane'. Please use a Boolean." if options[:two_pane].present? && !!options[:two_pane] != options[:two_pane]

      options.update(input_class: "#{options[:input_class]} multiselect") if options[:two_pane] == true

      fae_association f, attribute, options
    end

    def fae_datepicker(f, attribute, options={})


      fae_input f, attribute, as: :string, wrapper_class: 'datepicker'
    end

    def fae_grouped_select(f, attribute, options={})
      raise "MissingRequiredOption: fae_grouped_select requires a `collection` option or `groups` and `labels` options." if !options.has_key?(:collection) && !options.has_key?(:groups) && !options.has_key?(:labels)
      raise "MissingRequiredOption: fae_grouped_select required a `labels` option with a value containing an array when using the `groups` option." if options[:groups].present? && options[:labels].blank?
      raise "MissingRequiredOption: fae_grouped_select required a `groups` option with a value containing an array when using the `labels` option." if options[:labels].present? && options[:groups].blank?

      options[:collection] ||= group_options_for_collection(options[:labels], options[:groups])
      options.update(as: :grouped_select, group_method: :last, wrapper_class: "#{options[:wrapper_class]} select")

      association_or_input f, attribute, options
    end

    def fae_video_url(f, attribute, options={})
      raise "Fae:ImproperOptionValue: can't override helper_text or hint options for fae_video_url" if options[:helper_text].present? || options[:hint].present?
      options.update helper_text: "Please enter your YouTube video ID. The video ID is between v= and & of the video's url. This is typically 11 characters long.", hint: "#{image_tag('fae/youtube_helper.jpg')}"
      fae_input f, attribute, options
    end


    private

    def custom_options(options)
      options[:input_html] = { class: options[:input_class] } if options[:input_class].present?
      options.update(wrapper_class: "#{options[:wrapper_class]} input") if options[:wrapper_class].present?
      options.update(validate: true) unless options[:validate].present? && options[:validate] == false
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
      else
        raise "undefined method '#{attribute}' for #{f.object}"
      end
    end

    def symbol(type, val, options)
      options[:as] = :symbol
      options[:wrapper_class] = options[:wrapper_class].present? ? "#{options[:wrapper_class]} input symbol--#{type}" : "input symbol--#{type}"
      options[:span_class]  = "input-symbol--#{type}"
      options[:span_class] += " icon-#{val}" if options[:icon].present?

      options[:content_text] = val if options[:icon].blank?
    end

    def group_options_for_collection(labels, groups)
      raise "groups and labels must be an array" if !(labels.is_a? Array) || !(groups.is_a? Array)
      raise "grouped options must be arrays of equal length. label length: #{labels.length}, options_length: #{groups.length}" if labels.length != groups.length

      collection = {}
      labels.each_with_index { |label, i| collection[label] = groups[i] }
      collection
    end

  end
end
