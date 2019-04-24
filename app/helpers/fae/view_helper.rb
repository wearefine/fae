module Fae
  module ViewHelper

    def fae_date_format(datetime, timezone = @option.time_zone)
      datetime.in_time_zone(timezone).strftime('%m/%d/%y') if is_date_or_time?(datetime)
    end

    def fae_datetime_format(datetime, timezone = @option.time_zone)
      datetime.in_time_zone(timezone).strftime("%b %-d, %Y %l:%M%P %Z") if is_date_or_time?(datetime)
    end

    def fae_path
      Rails.application.routes.url_helpers.fae_path[1..-1]
    end

    def fae_image_form(f, image_name, label: nil, alt_label: nil, caption_label: nil, show_alt: nil, show_caption: nil, required: nil, helper_text: nil, alt_helper_text: nil, caption_helper_text: nil, attached_as: nil)
      render 'fae/images/image_uploader', f: f, image_name: image_name, label: label, alt_label: alt_label, caption_label: caption_label, show_alt: show_alt, show_caption: show_caption, required: required, helper_text: helper_text, alt_helper_text: alt_helper_text, caption_helper_text: caption_helper_text, attached_as: attached_as
    end

    def fae_file_form(f, file_name, label: nil, helper_text: nil, required: nil)
      render 'fae/application/file_uploader', f: f, file_name: file_name, label: label, required: required, helper_text: helper_text
    end

    def fae_content_form(f, attribute, label: nil, hint: nil, helper_text: nil, markdown: nil, markdown_supported: nil, input_options: nil)
      render 'fae/application/content_form', f: f, attribute: attribute, label: label, hint: hint, helper_text: helper_text, markdown: markdown, markdown_supported: markdown_supported, input_options: input_options
    end

    def fae_index_image(image, path = nil)
      return if image.blank? || image.asset.blank? || image.asset.thumb.blank?
      content_tag :div, class: 'image-mat' do
        link_to_if path.present?, image_tag(image.asset.thumb.url), path
      end
    end

    def fae_toggle(item, column)
      active = item.send(column)
      link_class = active ? 'slider-yes-selected' : ''
      model_name = item.class.to_s.gsub('::','__').underscore.pluralize
      url = fae.toggle_path(model_name, item.id.to_s, column)

      link_to url, class: "slider-wrapper #{link_class}", method: :post, remote: true do
        '<div class="slider-options">
          <div class="slider-option slider-option-yes">Yes</div>
          <div class="slider-option-selector"></div>
          <div class="slider-option slider-option-no">No</div>
        </div>'.html_safe
      end
    end

    def fae_clone_button(item)
      return if item.blank?
      link_to "#{@index_path}?from_existing=#{item.id}", method: :post, title: 'Clone', class: 'js-tooltip table-action', data: { confirm: t('fae.clone_confirmation') } do
        concat content_tag :i, nil, class: 'icon-copy'
      end
    end

    def fae_delete_button(item, delete_path = nil, *custom_attrs)
      return if item.blank?
      delete_path ||= polymorphic_path([main_app, fae_scope, item.try(:fae_parent), item])
      attrs = { method: :delete, title: 'Delete', class: 'js-tooltip table-action', data: { confirm: t('fae.delete_confirmation') } }
      attrs.deep_merge!(custom_attrs[0]) if custom_attrs.present?
      link_to delete_path, attrs do
        concat content_tag :i, nil, class: 'icon-trash'
      end
    end

    def fae_sort_id(item)
      return if item.blank?
      klass = item.class.name.underscore.gsub('/','__')
      "#{klass}_#{item.id}"
    end

    def fae_filter_form(options = {}, &block)
      options = prepare_options_for_filter_form options
      return if options[:collection].blank?

      form_tag(options[:action], prepare_form_filter_hash(options)) do
        concat prepare_filter_header(options)

        if block_given?
          filter_group_wrapper = content_tag(:div, class: 'table-filter-group-wrapper') do
            link_tag = content_tag(:a,
                                   t('fae.reset_search'),
                                   class: 'js-reset-btn button -small hidden',
                                   href: '#')
            concat capture(&block)
            concat content_tag(:div,
                               link_tag,
                               class: 'table-filter-group')
          end
        end
        concat filter_group_wrapper
        # I know this `unless !` looks like it should be an `if` but it's definitely supposed to be `unless !`
        unless !options[:search]
          concat submit_tag t('fae.apply_filters'), class: 'hidden'
        end
      end
    end

    def fae_filter_select(attribute, opts = {})
      options = prepare_options_for_filter_select(attribute, opts)
      # grouped_by takes priority over grouped_options
      if options[:grouped_by].present?
        select_options = filter_generate_select_group(options[:collection], options[:grouped_by], options[:label_method])
      elsif options[:grouped_options].present?
        select_options = grouped_options_for_select(options[:grouped_options])
      else
        select_options = options_from_collection_for_select(options[:collection], 'id', options[:label_method])
        select_options = options_for_select(options[:options]) if options[:options].present?
      end

      content_tag :div, class: 'table-filter-group' do
        concat label_tag "filter[#{attribute}]", options[:label]
        concat select_tag "filter[#{attribute}]", select_options, prompt: options[:placeholder]
      end
    end

    def fae_avatar(user = current_user)
      hash = Digest::MD5.hexdigest(user.email.downcase)
      "https://secure.gravatar.com/avatar/#{hash}?s=80&d=mm"
    end

    def fae_paginate(items)
      content_tag :nav, class: 'pagination', data: { filter_path: "#{@index_path}/filter" } do
        paginate items, theme: 'fae'
      end
    end

    private

    def filter_search_field
      content_tag :div, class: 'table-filter-keyword-wrapper' do
        concat text_field_tag('filter[search]',
                              nil,
                              placeholder: t('fae.keyword_search'))
        concat content_tag(:i, '', class: 'icon-search')
      end
    end

    def filter_generate_select_group(collection, grouped_by, label_method)
      labels = collection.map { |c| c.send(grouped_by).try(:fae_display_field) }.uniq
      grouped_hash = {}

      labels.each do |label|
        values = collection.select { |c| c.send(grouped_by).try(:fae_display_field) == label }
        grouped_hash[label] = values.map { |v| [v.send(label_method), v.id] }
      end

      grouped_options_for_select(grouped_hash)
    end

    def default_collection_from_attribute(attribute)
      attribute.to_s.classify.constantize.for_fae_index
    rescue NameError
      []
    end

    def is_date_or_time?(datetime)
      datetime.present? && ( datetime.kind_of?(Date) || datetime.kind_of?(Time) || datetime.kind_of?(ActiveSupport::TimeWithZone) )
    end

    def try_placeholder_translation(attribute, path, label)
      items = try_translation(attribute, path) || label
      t('fae.all_items', items: items)
    end

    def prepare_options_for_filter_select(attribute, options)
      options = preprare_label_for_filter_select attribute, options
      options = prepare_placeholder_for_filter_select attribute, options
      options[:collection] ||= default_collection_from_attribute(attribute)
      options[:label_method] ||= :fae_display_field
      options[:options] ||= []
      options[:grouped_by] ||= nil
      options[:grouped_options] ||= []
      options
    end

    def preprare_label_for_filter_select(attribute, options)
      options[:label] ||= try_translation(attribute.to_s,
                                          options[:translation_path]) ||
                          attribute.to_s.titleize
      options
    end

    def prepare_placeholder_for_filter_select(attribute, options)
      if options[:placeholder].nil?
        options[:placeholder] = try_placeholder_translation(
          attribute.to_s.pluralize,
          options[:translation_path],
          options[:label].pluralize
        )
      end
      options
    end

    def prepare_options_for_filter_form(options)
      options[:collection] ||= @items
      options[:action] ||= "#{@index_path}/filter"
      options[:title] ||= t('fae.search',
                            search: @klass_humanized.pluralize.titleize)

      options[:search] = true if options[:search].nil?
      options[:cookie_key] ||= false
      options
    end

    def prepare_filter_header(options)
      content_tag(:div, class: 'table-filter-header') do
        concat content_tag :h4, options[:title]
        concat filter_search_field if options[:search]
      end
    end

    def prepare_form_filter_hash(options)
      form_hash = { class: 'js-filter-form table-filter-area' }
      form_hash['data-cookie-key'] = options[:cookie_key] if options[:cookie_key].present?
      form_hash
    end
  end
end
