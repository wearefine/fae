module Fae
  module FormHelper

    def fae_input(f, attribute, options={})
      custom_options attribute, options
      label_and_hint attribute, options
      list_order f, attribute, options
      set_prompt f, attribute, options

      f.input attribute, options
    end

    def fae_association(f, attribute, options={})
      custom_options attribute, options
      label_and_hint attribute, options
      list_order f, attribute, options
      set_prompt f, attribute, options

      f.association attribute, options
    end

    def fae_prefix(f, attribute, options={})
      raise "Fae::undefined method '#{attribute}' for #{f.object}" if is_attribute_or_association?(f, attribute) == false
      raise "Fae::MissingRequiredOption: fae_prefix helper method requires the 'prefix' option." if options[:prefix].blank?
      symbol 'prefix', options[:prefix], options
      fae_input f, attribute, options
    end

    def fae_suffix(f, attribute, options={})
      raise "Fae::undefined method '#{attribute}' for #{f.object}" if is_attribute_or_association?(f, attribute) == false
      raise "Fae::MissingRequiredOption: fae_suffix helper method requires the 'suffix' option." if options[:suffix].blank?
      symbol 'suffix', options[:suffix], options
      fae_input f, attribute, options
    end


    def fae_radio(f, attribute, options={})
      options[:alignment] = 'radio_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'radio_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?
      options.update(as: :radio_collection, wrapper_class: "#{options[:wrapper_class]} #{options[:alignment]}", no_label_div: true)
      association_or_input f, attribute, options
    end

    def fae_checkbox(f, attribute, options={})
      options[:alignment] = 'checkbox_collection--horizontal' if options[:type] == 'inline'
      options[:alignment] = 'checkbox_collection--vertical' if options[:type] == 'stacked' || options[:type].blank?
      options.update(as: :check_boxes, wrapper_class: "#{options[:wrapper_class]} #{options[:alignment]}", no_label_div: true)
      association_or_input f, attribute, options
    end

    def fae_pulldown(f, attribute, options={})
      raise "Fae::MissingRequiredOption: fae_pulldown requires a 'collection' when using it on an ActiveRecord attribute." if !options.has_key?(:collection) && f.object.attribute_names.include?(attribute.to_s)
      raise "Fae::ImproperOptionValue: The value #{options[:size]} is not a valid option for 'size'. Please use 'short' or 'long'." if options[:size].present? && ['short','long'].include?(options[:size]) == false
      raise "Fae::ImproperOptionValue: The value #{options[:search]} is not a valid option for 'search'. Please use a Boolean." if options[:search].present? && !!options[:search] != options[:search]

      add_input_class(options, 'small_pulldown') if options[:size] == "short"
      add_input_class(options, 'select-search') if options[:search]
      options.update(wrapper_class: "#{options[:wrapper_class]} select-no_search") if options[:search] == false
      association_or_input f, attribute, options
    end

    def fae_multiselect(f, attribute, options={})
      raise "Fae::'#{attribute}' must be an association of #{f.object}" if !is_association?(f, attribute)
      raise "Fae::ImproperOptionValue: The value '#{options[:two_pane]}' is not a valid option for 'two_pane'. Please use a Boolean." if options[:two_pane].present? && !!options[:two_pane] != options[:two_pane]

      options.update(input_class: "#{options[:input_class]} multiselect") if options[:two_pane] == true
      fae_association f, attribute, options
    end

    def fae_datepicker(f, attribute, options={})
      options.update(as: :string, wrapper_class: 'datepicker')
      fae_input f, attribute, options
    end

    def fae_daterange(f, attr_array, options={})
      raise "Fae::MissingRequiredOption: fae_daterange requires the 'label' option." if options[:label].blank?
      raise "Fae::MalformedArgument: fae_daterange requires an array of two attributes as it's second argument." unless attr_array.present? && attr_array.is_a?(Array) && attr_array.length == 2
      options.update(as: :date_range, start_date: attr_array.first, end_date: attr_array.second)
      fae_input f, options[:label], options
    end

    def fae_grouped_select(f, attribute, options={})
      raise "Fae::MissingRequiredOption: fae_grouped_select requires a `collection` option or `groups` and `labels` options." if !options.has_key?(:collection) && !options.has_key?(:groups) && !options.has_key?(:labels)
      raise "Fae::MissingRequiredOption: fae_grouped_select required a `labels` option with a value containing an array when using the `groups` option." if options[:groups].present? && options[:labels].blank?
      raise "Fae::MissingRequiredOption: fae_grouped_select required a `groups` option with a value containing an array when using the `labels` option." if options[:labels].present? && options[:groups].blank?

      options[:collection] ||= group_options_for_collection(options[:labels], options[:groups])
      options.update(as: :grouped_select, group_method: :last, wrapper_class: "#{options[:wrapper_class]} select")
      association_or_input f, attribute, options
    end

    def fae_video_url(f, attribute, options={})
      options[:helper_text] ||= "Please enter your YouTube video ID. The video ID is between v= and & of the video's url. This is typically 11 characters long."
      options[:hint] ||= "#{image_tag('fae/youtube_helper.jpg')}"
      options[:input_class] = "#{options[:input_class]} youtube-api"
      fae_input f, attribute, options
    end


    private

    def custom_options(attribute, options)
      add_input_class(options, options[:input_class]) if options[:input_class].present?
      add_input_class(options, 'slug') if attribute == :slug
      options.update(wrapper_class: "#{options[:wrapper_class]} input") if options[:wrapper_class].present?
      options.update(validate: true) unless options[:validate].present? && options[:validate] == false
    end

    def label_and_hint(attribute, options)
      raise "Fae::ConflictingOptions: the `hint` and `dark_hint` options must not be used at the same time." if options[:hint].present? && options[:dark_hint].present?

      attribute_name = options[:as].to_s == 'hidden' ? '' : attribute.to_s.titleize
      label = options[:label] || attribute_name
      if options[:markdown].present? || options[:helper_text].present?
        label += content_tag :h6, class: 'helper_text' do
          concat(options[:helper_text]) if options[:helper_text].present?
          concat(content_tag(:span, 'Markdown Supported', class: 'markdown-support')) if options[:markdown].present?
        end
      end
      options[:label] = label.html_safe if label.present?

      options[:hint] = "#{options[:hint]}".html_safe if options[:hint].present?
      options[:hint] = "<div class='dark'>#{options[:dark_hint]}</div>".html_safe if options[:dark_hint].present?
    end

    def is_attribute_or_association?(f, attribute)
      f.object.has_attribute?(attribute) || is_association?(f, attribute)
    end

    def is_association?(f, attribute)
      f.object.class.reflections.include?(attribute) || f.object.class.reflections.include?(attribute.to_s)
    end

    def association_or_input(f, attribute, options)
      if is_attribute_or_association?(f, attribute)
        f.object.attribute_names.include?(attribute.to_s) ? fae_input(f, attribute, options) : fae_association(f, attribute, options)
      else
        raise "Fae::undefined method '#{attribute}' for #{f.object}"
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
      raise "Fae::groups and labels must be an array" if !(labels.is_a? Array) || !(groups.is_a? Array)
      raise "Fae::grouped options must be arrays of equal length. label length: #{labels.length}, options_length: #{groups.length}" if labels.length != groups.length

      collection = {}
      labels.each_with_index { |label, i| collection[label] = groups[i] }
      collection
    end

    def to_class(attribute)
      attribute.to_s.classify.constantize
    end

    def add_input_class(options, class_name)
      if options.key?(:input_html)
        options[:input_html] = { class: "#{options[:input_html][:class]} #{class_name}" }
      else
        options[:input_html] = { class: class_name }
      end
    end

    # sets collection to class.for_fae_index if not defined
    def list_order(f, attribute, options)
      if is_association?(f, attribute) && !options[:collection]
        begin
          options[:collection] = to_class(attribute).for_fae_index
        rescue NameError
          raise "Fae::MissingCollection: `#{attribute}` isn't an orderable class, define your order using the `collection` option."
        end
      end
    end

    # sets default prompt for pulldowns
    def set_prompt(f, attribute, options)
      options[:prompt] = 'Select One' if is_association?(f, attribute) && !options[:prompt] && !options[:two_pane]
    end

  end
end
