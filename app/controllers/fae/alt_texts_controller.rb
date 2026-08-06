module Fae
  class AltTextsController < ApplicationController
    include Fae::InertiaRenderable

    def index
      @items = fae_alt_text_relation.page(params[:page])

      render inertia: 'Fae/AltTexts', props: {
        title: t('fae.application.alt_texts_heading'),
        indexPath: fae.alt_texts_path,
        filters: {
          title: t('fae.application.alt_texts_filter'),
          fields: fae_alt_text_filter_fields,
          values: fae_alt_text_filter_values
        },
        rows: @items.map { |item| fae_alt_text_row(item) },
        pagination: fae_alt_text_pagination(@items),
        canGenerateAlt: fae_open_ai_enabled?,
        generateAltPath: fae.generate_alt_path,
        emptyText: 'No items found'
      }
    end

    def update_alt
      image = Fae::Image.find_by_id(params[:id])
      image.update_attribute(:alt, params[:alt])
      head :ok
    end

    def filter
      if request.inertia?
        redirect_to fae.alt_texts_path(fae_alt_text_filter_values.merge(page: params[:page]).compact)
      else
        @items = Fae::Image.filter(params).fae_sort(params).page(params[:page])
        render :index, layout: false
      end
    end

    private

    def fae_alt_text_relation
      filters = fae_alt_text_filter_values
      scope = filters.values.any?(&:present?) ? Fae::Image.filter(filters) : Fae::Image.for_fae_index
      scope.fae_sort(params)
    end

    def fae_alt_text_filter_values
      params.permit(:alt_text_presence, :parent_model, :attached_as, :search).to_h
    end

    def fae_alt_text_filter_fields
      [
        {
          key: 'alt_text_presence',
          label: 'Alt Text Presence',
          type: 'select',
          placeholder: t('fae.all_items', items: 'Alt Text'),
          options: [
            { label: 'Both', value: 'Both' },
            { label: 'Missing', value: 'Missing' },
            { label: 'Present', value: 'Present' }
          ]
        },
        {
          key: 'parent_model',
          label: 'Parent Model',
          type: 'select',
          placeholder: t('fae.all_items', items: 'Parent Models'),
          options: fae_alt_text_parent_model_options.map { |label, value| { label: label, value: value } }
        },
        {
          key: 'attached_as',
          label: 'Attached As',
          type: 'select',
          placeholder: t('fae.all_items', items: 'Attachment Types'),
          options: Fae::Image.pluck(:attached_as).uniq.compact.map { |value| { label: value.titleize, value: value } }
        }
      ]
    end

    def fae_alt_text_parent_model_options
      options = []

      Fae::StaticPage.all.each do |page|
        options << ["#{page.title} Page", "Fae::StaticPage-#{page.id}"]
      end

      Fae::Image.pluck(:imageable_type).uniq.compact.each do |model|
        next if ['Fae::StaticPage', 'Fae::Option'].include?(model)
        options << [model.titleize, model]
      end

      options
    end

    def fae_alt_text_row(item)
      parent_model = if item.imageable_type == 'Fae::StaticPage'
        "#{item.imageable&.title || 'Static'} Page"
      else
        item.imageable_type&.titleize
      end

      {
        id: item.id,
        imageUrl: item.asset&.url,
        parentModel: parent_model,
        parentId: (item.imageable_id unless item.imageable_type == 'Fae::StaticPage'),
        attachedAs: item.attached_as&.titleize,
        alt: item.alt.to_s,
        fileSize: helpers.number_to_human_size(item.file_size),
        modified: helpers.fae_date_format(item.updated_at),
        updatePath: "#{fae.alt_texts_path}/#{item.id}/update_alt"
      }
    end

    def fae_alt_text_pagination(items)
      {
        currentPage: items.current_page,
        totalPages: items.total_pages,
        totalCount: items.total_count,
        perPage: Fae.per_page,
        prevPage: items.prev_page,
        nextPage: items.next_page
      }
    end

    def fae_open_ai_enabled?
      Fae.open_ai_api_key.present?
    end

  end
end
