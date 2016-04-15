module Fae
  module  ViewHelper

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

    def attr_toggle(item, column)
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
    # for backwards compatibility
    alias_method :fae_toggle, :attr_toggle

    def fae_clone_button(item)
      return if item.blank?
      link_to "#{@index_path}?from_existing=#{item.id}", method: :post, title: 'Clone', class: 'js-tooltip table-action', data: { confirm: t('fae.clone_confirmation') } do
        concat content_tag :i, nil, class: 'icon-copy'
      end
    end

    def fae_delete_button(item, delete_path = nil)
      return if item.blank?
      delete_path ||= polymorphic_path([main_app, fae_scope, item.try(:fae_parent), item])
      link_to delete_path, method: :delete, title: 'Delete', class: 'js-tooltip table-action', data: { confirm: t('fae.delete_confirmation') } do
        concat content_tag :i, nil, class: 'icon-trash'
      end
    end

    def fae_sort_id(item)
      return if item.blank?
      klass = item.class.name.underscore.gsub('/','__')
      "#{klass}_#{item.id}"
    end

    def fae_filter_form(options = {}, &block)
      options[:collection] ||= @items
      options[:action]     ||= "#{@index_path}/filter"
      options[:title]      ||= "Search #{@klass_humanized.pluralize.titleize}"
      options[:search]       = true if options[:search].nil?
      options[:cookie_key] ||= false

      return if options[:collection].blank?

      form_hash = { remote: true, class: 'js-filter-form table-filter-area' }
      form_hash['data-cookie-key'] = options[:cookie_key] if options[:cookie_key].present?

      filter_header = content_tag(:div, class: 'table-filter-header') do
        concat content_tag :h4, options[:title]
        concat filter_search_field if options[:search]
      end

      form_tag(options[:action], form_hash) do
        concat filter_header

        filter_group_wrapper = content_tag(:div, class: 'table-filter-group-wrapper') do
          concat capture(&block)
          concat filter_submit_btns
        end

        concat filter_group_wrapper
      end
    end

    def fae_filter_select(attribute, options = {})
      options[:label]           ||= attribute.to_s.titleize
      options[:collection]      ||= default_collection_from_attribute(attribute)
      options[:label_method]    ||= :fae_display_field
      options[:placeholder]       = "All #{options[:label].pluralize}" if options[:placeholder].nil?
      options[:options]         ||= []
      options[:grouped_by]      ||= nil
      options[:grouped_options] ||= []

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

    private

    def filter_search_field
      content_tag :div, class: 'table-filter-keyword-wrapper' do
        text_field_tag 'filter[search]', nil, placeholder: 'Search by Keyword', class: 'table-filter-keyword-input'
      end
    end

    def filter_submit_btns
      content_tag :div, class: 'table-filter-controls' do
        concat submit_tag 'Apply Filters'
        concat submit_tag 'Reset Search', class: 'js-reset-btn table-filter-reset'
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
      datetime.present? && ( datetime.kind_of?(Date) || datetime.kind_of?(Time) )
    end

  end
end
