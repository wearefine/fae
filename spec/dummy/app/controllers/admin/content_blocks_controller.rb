class Admin::ContentBlocksController < Fae::StaticPagesController
  include Fae::InertiaRenderable

  def index
    return super unless request.inertia?

    items = fae_pages.map(&:instance)

    render inertia: 'Fae/Index', props: {
      title: t('fae.page.title'),
      newPath: nil,
      newButtonText: nil,
      columns: [
        { key: 'name', label: t('fae.common.name') },
        { key: 'modified', label: 'Modified' }
      ],
      rows: items.map do |item|
        {
          id: item.id,
          label: item.fae_display_field.to_s,
          editPath: fae.edit_content_block_path(slug: item.slug),
          deletePath: nil,
          cells: {
            'name' => item.title.to_s.titleize,
            'modified' => helpers.fae_date_format(item.updated_at)
          }
        }
      end,
      groups: nil,
      sortable: false,
      sortPath: nil,
      sortParam: nil,
      inertiaLinks: true
    }
  end

  def edit
    build_assocs
    params[:static_page] = true

    fields = static_page_form_fields

    render inertia: 'Fae/Form', props: {
      title: "Edit #{@item.title}",
      indexPath: @index_path,
      submitPath: fae.update_content_block_path(slug: @item.slug),
      submitMethod: 'put',
      paramKey: @item.model_name.param_key,
      blocks: fae_inertia_form_blocks(@item, fields, false),
      subnav: static_page_subnav,
      draft: false,
      deletePath: nil,
    }
  end

  def update
    return super unless request.inertia?

    if @item.update(inertia_item_params)
      redirect_to @index_path, notice: t('fae.save_notice')
    else
      redirect_to fae.edit_content_block_path(slug: @item.slug),
                  inertia: { errors: fae_inertia_errors(@item) },
                  flash: { alert: t('fae.save_error') }
    end
  end

  private

  def static_page_form_fields
    return nested_tables_in_form_fields if @item.slug == 'nested_tables_in_form'

    fields = [{ name: :title, type: :text }.merge(static_page_title_section)]
    fields.concat(static_page_content_fields)
    fields.concat(static_page_extra_blocks)
    fields
  end

  def static_page_content_fields
    @item.class.fae_fields.filter_map do |name, raw_config|
      config = raw_config.is_a?(Hash) ? raw_config : { type: raw_config }
      type = static_page_field_type(config[:type])
      next if type.blank?

      options = static_page_field_overrides[name.to_sym] || {}
      {
        name: name,
        type: type
      }.merge(options).merge(static_page_field_section(name.to_sym))
    end
  end

  def static_page_field_type(field_class)
    class_name = field_class.to_s
    return :text if class_name == 'Fae::TextField'
    return :textarea if class_name == 'Fae::TextArea'
    return :image if class_name == 'Fae::Image'
    return :file if class_name == 'Fae::File'

    nil
  end

  def static_page_field_overrides
    {
      home: {
        introduction_2: { markdown: true },
        body: {
          markdown: true,
          helper_text: 'Supports markdown formatting.'
        }
      },
      about_us: {
        introduction: { markdown: true },
        body: {
          markdown: true,
          helper_text: 'Supports markdown formatting.'
        }
      },
      contact_us: {
        body: {
          markdown: true,
          helper_text: 'Supports markdown formatting.'
        }
      },
      privacy: {
        body: { markdown: true }
      }
    }.fetch(@item.slug.to_sym, {})
  end

  def static_page_extra_blocks
    case @item.slug
    when 'home'
      [
        {
          name: :aroma_ids,
          type: :ranked_select,
          association: :aromas,
          join_model: :static_page_aromas,
          label: 'Aromas',
          helper_text: 'Select aromas and drag to rank them in order of prominence.',
          ranking_title: 'Aroma Ranking',
          ranking_helper_text: 'Drag to reorder aromas by prominence',
          collection: Aroma.for_fae_index,
          section_id: 'top'
        },
        {
          flex_components_table: :flex_components,
          title: 'Components',
          section_id: 'components',
          section_title: 'Components'
        }
      ]
    when 'components'
      [
        {
          flex_components_table: :flex_components,
          title: 'Components',
          section_id: 'components',
          section_title: 'Components'
        }
      ]
    else
      []
    end
  end

  def nested_tables_in_form_fields
    fields = [{ name: :title, type: :text }.merge(static_page_title_section)]
    by_name = static_page_content_fields.index_by { |field| field[:name].to_sym }

    fields << by_name[:list_header] if by_name[:list_header]
    fields << by_name[:list_introduction] if by_name[:list_introduction]
    fields << {
      nested_table: :list_items,
      cols: [:name, :people, :on_stage, :on_prod],
      title: 'List Items',
      section_id: 'list',
      section_title: 'List'
    }

    fields << by_name[:flex_header] if by_name[:flex_header]
    fields << by_name[:flex_introduction] if by_name[:flex_introduction]
    fields << {
      flex_components_table: :flex_components,
      title: 'Components',
      section_id: 'components',
      section_title: 'Components'
    }

    fields << by_name[:seo_title] if by_name[:seo_title]
    fields << by_name[:seo_description] if by_name[:seo_description]
    fields << by_name[:social_media_title] if by_name[:social_media_title]
    fields << by_name[:social_media_description] if by_name[:social_media_description]
    fields << by_name[:social_media_image] if by_name[:social_media_image]

    fields
  end

  def static_page_subnav
    case @item.slug
    when 'home'
      [{ label: 'Top', target: 'top' }]
    when 'nested_tables_in_form'
      [
        { label: 'Top', target: 'top' },
        { label: 'List', target: 'list' },
        { label: 'Components', target: 'components' },
        { label: 'SEO', target: 'seo' }
      ]
    else
      []
    end
  end

  def static_page_title_section
    section = static_page_subnav.find { |entry| entry[:target] == 'top' }
    return {} if section.blank?

    { section_id: 'top', section_title: section[:label] }
  end

  def static_page_field_section(name)
    return {} unless @item.slug == 'nested_tables_in_form'

    list_fields = %i[list_header list_introduction]
    component_fields = %i[flex_header flex_introduction]
    seo_fields = %i[seo_title seo_description social_media_title social_media_description social_media_image]

    return { section_id: 'list', section_title: 'List' } if list_fields.include?(name)
    return { section_id: 'components', section_title: 'Components' } if component_fields.include?(name)
    return { section_id: 'seo', section_title: 'SEO' } if seo_fields.include?(name)

    {}
  end

  def inertia_item_params
    raw = item_params.to_h.deep_dup

    raw.each do |key, value|
      next unless key.to_s.end_with?('_ids')

      ids = case value
            when Array
              value
            when Hash
              value.values
            else
              Array(value)
            end

      raw[key] = ids.filter_map do |entry|
        next if entry.blank?

        id = entry.to_i
        id.positive? ? id : nil
      end.uniq
    end

    @item.class.fae_fields.each do |name, raw_config|
      config = raw_config.is_a?(Hash) ? raw_config : { type: raw_config }
      class_name = config[:type].to_s
      next unless class_name == 'Fae::TextField' || class_name == 'Fae::TextArea'

      key = name.to_s
      next unless raw.key?(key)

      content = raw.delete(key)
      association = @item.public_send(name)
      raw["#{key}_attributes"] = {
        id: association&.id,
        content: content,
        attached_as: association&.attached_as || key,
      }.compact
    end

    raw
  end

  def fae_pages
    [HomePage, AboutUsPage, ContactUsPage, GlobalContentPage, PrivacyPage, ComponentsPage, NestedTablesInFormPage]
  end

  def use_pagination
    true
  end
end
