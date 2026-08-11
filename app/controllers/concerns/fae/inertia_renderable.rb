module Fae
  # Shared rendering/writing behavior for Fae screens backed by Inertia + Vue.
  #
  # Kept as a concern so Fae::BaseController stays focused on core controller
  # setup while the Inertia layer evolves independently.
  module InertiaRenderable
    extend ActiveSupport::Concern
    include Fae::InertiaErrors
    include Fae::InertiaSharedProps

    # Field types backed by a has_one Fae::Image / Fae::File rather than a
    # column, so they submit as nested attributes.
    ASSET_FIELD_TYPES = %w[image file].freeze

    included do
      inertia_config layout: 'fae/inertia'

      inertia_share do
        {
          rootPath: fae.root_path,
          currentUser: fae_inertia_current_user,
          flash: fae_inertia_flash,
          languageNav: fae_inertia_language_nav,
          nav: fae_inertia_nav,
          utilityNav: fae_inertia_utility_nav,
          theme: fae_inertia_theme
        }
      end
    end

    def create
      return super if params[:from_existing].present?

      @item = @klass.new(item_params)

      if @item.save
        redirect_to fae_inertia_success_path(@item), notice: t('fae.save_notice')
      else
        # Only reachable for a model that overrides #new to stop creating a
        # draft; the standard flow always PUTs to an already-persisted record.
        # Redirecting to #new re-enters the draft flow, and the user's input is
        # preserved client-side because the page component does not remount.
        redirect_to @new_path, inertia: { errors: fae_inertia_errors(@item) },
                               flash: { alert: t('fae.save_error') }
      end
    end

    def update
      @item.draft = false if @klass.has_fae_draft_support?

      if @item.update(item_params)
        redirect_to fae_inertia_success_path(@item), notice: t('fae.save_notice')
      else
        # Redirect rather than re-render: Inertia's protocol has no equivalent
        # of `render action: 'edit'`, and the errors survive the redirect in
        # the session (see inertia_rails' capture_inertia_session_options).
        # `draft` is carried through so cancelling still deletes the record the
        # #new action created.
        redirect_to build_edit_path(@item, fae_inertia_draft_param),
                    inertia: { errors: fae_inertia_errors(@item) },
                    flash: { alert: t('fae.save_error') }
      end
    end

    private

    # #new persists the record immediately and redirects to #edit with
    # ?draft=true, so a failed save has to put the flag back on the URL or the
    # Cancel button would stop offering to delete the record it created.
    def fae_inertia_draft_param
      params[:draft] == 'true' ? { draft: true } : {}
    end

    # Override for resources that should remain on edit after a successful save.
    # Only applies to top-level resources; nested controllers keep their
    # parent-form redirect flow.
    def fae_inertia_stay_on_form_after_save?
      false
    end

    def fae_inertia_success_path(item)
      return @index_path unless fae_inertia_stay_on_form_after_save?
      return @index_path if parent_resource_param.present?

      build_edit_path(item)
    end

    def fae_inertia_current_user
      return nil if current_user.blank?

      # fae_display_field is host-overridable and often left unset, and
      # full_name is blank for an account created without a name, so fall all
      # the way back to the email rather than shipping an empty label to the
      # header chip.
      name = current_user.try(:fae_display_field).presence ||
             current_user.try(:full_name).to_s.strip.presence ||
             current_user.email

      { id: current_user.id, name: name }
    end

    # Mirrors the legacy language switcher used by form_header when a form has
    # translated fields, but ships as data so Vue can decide when to render it.
    def fae_inertia_language_nav
      return nil if Fae.languages.blank?

      options = [{ value: 'all', label: 'All Languages' }]
      options.concat(
        Fae.languages.map do |language_code, label|
          { value: language_code.to_s, label: label.to_s }
        end
      )

      selected = current_user&.language.to_s
      valid_values = options.map { |option| option[:value] }
      selected = 'all' unless valid_values.include?(selected)

      {
        options: options,
        selected: selected,
        savePathBase: "#{fae.root_path.to_s.chomp('/')}/language_preference",
        translateEnabled: fae_inertia_language_translate_enabled?,
        translatePath: (fae.translate_text_path if fae_inertia_language_translate_enabled?)
      }
    end

    def fae_inertia_language_translate_enabled?
      Fae::Option.instance.translate_language &&
        ENV['TRANSLATOR_TEXT_SUBSCRIPTION_KEY'].present? &&
        ENV['TRANSLATOR_TEXT_REGION'].present?
    end

    # Fae's navigation is a single tree, split across two chrome regions:
    # levels 1-2 render as the top nav, levels 3-4 as the side nav. Both are
    # built by ApplicationController#build_nav, and Fae::Navigation#side_nav
    # returns nil until the current path is at least three levels deep.
    def fae_inertia_nav
      {
        topnav: fae_inertia_nav_level(@fae_topnav_items, 0, :nested_path, :subitems),
        sidenav: fae_inertia_nav_level(@fae_sidenav_items, 2, :path, :sublinks)
      }
    end

    # Header utility items: a settings dropdown plus the signed-in account menu.
    def fae_inertia_utility_nav
      return [] unless current_user.present?

      items = []
      settings_children = []

      settings_children << {
        key: 'altTexts',
        text: t('fae.navbar.alt_text_manager'),
        path: fae.alt_texts_path
      }

      if current_user.super_admin_or_admin?
        settings_children << {
          key: 'activityLog',
          text: t('fae.navbar.activity_log'),
          path: fae.activity_log_path
        }
      end

      if current_user.super_admin?
        settings_children << {
          key: 'rootSettings',
          text: t('fae.navbar.root_settings'),
          path: fae.option_path
        }
        settings_children << {
          key: 'sites',
          text: t('fae.navbar.sites'),
          path: fae.sites_path
        }
      end

      if @option&.live_url.present?
        settings_children << {
          key: 'liveSite',
          text: t('fae.application.live_site'),
          path: @option.live_url,
          external: true
        }
      end

      if @option&.stage_url.present?
        settings_children << {
          key: 'stageSite',
          text: t('fae.application.stage_site'),
          path: @option.stage_url,
          external: true
        }
      end

      if settings_children.any?
        items << {
          key: 'settingsMenu',
          icon: 'gear',
          ariaLabel: 'Settings',
          children: settings_children
        }
      end

      if current_user.super_admin_or_admin?
        deployment_children = []

        if fae_inertia_netlify_enabled? && Fae::Site.any? { |site| site.netlify_site.present? && site.netlify_site_id.present? }
          deployment_children << {
            key: 'deploy-default',
            text: t('fae.navbar.deployments'),
            path: fae.deploy_path
          }
        end

        deployment_children.concat(Fae::Site.order(:name).filter_map do |site|
          next unless site.netlify_site.present? && site.netlify_site_id.present?

          {
            key: "deploy-site-#{site.id}",
            text: site.name.to_s,
            path: fae.deploy_path(site_id: site.id)
          }
        end)

        if deployment_children.any?
          deploy_item = {
            key: 'deploymentsMenu',
            icon: 'deploy',
            ariaLabel: t('fae.navbar.deployments'),
            current: params[:controller].to_s == 'fae/deploy',
            children: deployment_children
          }
          items << deploy_item
        end

      end

      items << {
        key: 'accountMenu',
        icon: 'avatar',
        ariaLabel: current_user.try(:full_name).presence || current_user.email,
        children: [
          {
            key: 'yourSettings',
            text: t('fae.navbar.your_settings'),
            path: fae.settings_path
          },
          {
            key: 'logout',
            text: t('fae.navbar.logout'),
            path: fae.destroy_user_session_path
          }
        ]
      }

      items
    end

    def fae_inertia_netlify_enabled?
      Fae.netlify.present? &&
        Fae.netlify[:api_user].present? &&
        Fae.netlify[:api_token].present? &&
        Fae.netlify[:api_base].present?
    end

    # Serializes one nav region: a list of items plus their immediate children.
    #
    # `level` is the item's depth in the tree, which is what
    # Fae::Navigation#coordinates indexes, so the top nav starts at 0 and the
    # side nav at 2. The two regions also disagree on which path to link:
    # the top nav uses :nested_path so a parent deep-links to its first
    # reachable child, while the side nav uses :path.
    def fae_inertia_nav_level(items, level, path_key, children_key)
      coordinates = Array(@fae_navigation&.coordinates)

      Array(items).each_with_index.map do |item, index|
        # Matches the -parent-current/-open state from nav_active_class: the
        # item is not itself the destination, it merely contains it.
        open = coordinates[level] == index

        children = Array(item[children_key]).each_with_index.map do |child, child_index|
          {
            text: child[:text],
            path: child[path_key],
            className: child[:class_name],
            current: open && coordinates[level + 1] == child_index
          }
        end

        {
          text: item[:text],
          path: item[path_key],
          className: item[:class_name],
          open: open,
          children: children
        }
      end
    end

    # Renders the generic Fae index. Mirrors Fae::BaseController#index, which is
    # itself model-agnostic, so the Vue page is driven purely by props.
    #
    #   render_fae_index(@klass.for_fae_index, columns: { name: 'Name' })
    #
    # Pass sortable: false to suppress drag-to-reorder on a model that has a
    # position column but is being listed in some other order.
    #
    # Pass `groups:` instead of `items` for a sectioned index -- the shape the
    # articles screen has always had, where the list is split by category and
    # each section reorders independently:
    #
    #   render_fae_index(groups: categories.map { |c| { title: c.name, items: c.articles } },
    #                    columns: { title: 'Title' })
    def render_fae_index(items = nil, columns:, groups: nil, sortable: nil, inertia_links: false)
      sortable = fae_inertia_sortable? if sortable.nil?
      keys = columns.keys
      title = @klass_humanized.pluralize.titleize

      render inertia: 'Fae/Index', props: {
        title: title,
        newPath: @new_path,
        # The button adds one record, so it names one -- as _index_header did.
        newButtonText: t('fae.common.add', title: title.singularize),
        columns: columns.map { |key, label| { key: key.to_s, label: label } },
        rows: Array(items).map { |item| fae_inertia_index_row(item, keys) },
        groups: groups&.map do |group|
          {
            title: group[:title],
            rows: Array(group[:items]).map { |item| fae_inertia_index_row(item, keys) }
          }
        end,
        sortable: sortable,
        # Reordering posts to the same Fae::UtilitiesController#sort action the
        # Slim screens use, so both variants persist positions identically.
        sortPath: (fae.sort_path(fae_inertia_sort_object) if sortable),
        sortParam: (fae_inertia_sort_object if sortable),
        # Only true once this resource's form is converted too -- see the note
        # in pages/Fae/Index.vue about <Link> and Slim targets.
        inertiaLinks: inertia_links
      }
    end

    # Renders the generic Fae form, the Vue counterpart of a resource's
    # _form.html.slim plus fae/shared/_form_header.
    #
    #   render_fae_form(fields: [
    #     { name: :article_category_id, type: :select, collection: [...] },
    #     { name: :title, type: :text, required: true }
    #   ])
    #
    # Every field is a plain hash rather than a builder call, because the props
    # have to survive serialization to JSON -- this is the seam that replaces
    # fae_input/fae_association.
    #
    # An entry keyed `nested_table:` renders a has_many table instead of an
    # input, and takes the same options fae/shared/_nested_table did. The list
    # is a single ordered one because the Slim form is a linear document: a
    # nested table belongs in its own place among the inputs, not swept to the
    # bottom of the page.
    #
    #   fields: [
    #     { name: :name, type: :text, required: true },
    #     { nested_table: :sub_spirits, cols: [:name] },
    #     { name: :content, type: :textarea, markdown: true }
    #   ]
    #
    # Types :image and :file are the fae_image_form / fae_file_form
    # counterparts. They take the same options those helpers did -- :show_alt,
    # :show_caption, :alt_label, :caption_label, :alt_helper_text,
    # :caption_helper_text -- and submit through the association that
    # has_fae_image / has_fae_file declared.
    #
    # `index_path`, `submit_path`, `submit_method`, `param_key` and
    # `delete_path` can be overridden for custom route shapes such as singleton
    # resources.
    def render_fae_form(item = @item, fields:, title: nil, subnav: nil, index_path: nil, submit_path: nil, submit_method: nil, param_key: nil, delete_path: :auto)
      # Fae::BaseController#new saves the record before redirecting here, so
      # "new" is really an edit of an unsaved-looking row. The draft flag is
      # what tells the Vue form that cancelling should delete it again.
      draft = params[:draft] == 'true'
      fields = fae_inertia_normalize_form_fields(fields)

      index_path ||= @index_path
      param_key ||= @klass_singular

      # The flag has to survive the round trip: it lives only in the query
      # string, and a failed save redirects back here off the submit URL.
      submit_path ||= item.persisted? ? "#{index_path}/#{item.id}" : index_path
      submit_method ||= item.persisted? ? 'put' : 'post'
      submit_path += '?draft=true' if draft

      delete_path = if delete_path == :auto
                      item.persisted? ? "#{index_path}/#{item.id}" : nil
                    else
                      delete_path
                    end

      render inertia: 'Fae/Form', props: {
        title: title || "#{draft ? 'New' : 'Edit'} #{@klass_humanized}".titleize,
        indexPath: index_path,
        # Both verbs are supported so this still works for a model that opts
        # out of the draft-on-new behaviour by overriding #new.
        submitPath: submit_path,
        submitMethod: submit_method,
        paramKey: param_key,
        blocks: fae_inertia_form_blocks(item, fields, draft),
        subnav: subnav.nil? ? fae_inertia_subnav_from_fields(fields) : fae_inertia_subnav(subnav),
        draft: draft,
        deletePath: delete_path
      }
    end

    # Flattens the form's declaration into an ordered list the page renders
    # top to bottom, so a nested table keeps its position among the inputs.
    def fae_inertia_form_blocks(item, fields, draft)
      fields.filter_map do |entry|
        section = fae_inertia_section_block_attrs(entry)

        if entry[:nested_table].present?
          # An unsaved parent has nothing to hang children off, the same reason
          # the Slim form wrapped its nested tables in `if @item.persisted?`.
          next unless item.persisted?

          { kind: 'nestedTable', table: fae_inertia_nested_table(item, entry, draft) }.merge(section)
        elsif entry[:flex_components_table].present?
          next unless item.persisted?

          { kind: 'flexComponentsTable', table: fae_inertia_flex_components_table(item, entry, draft) }.merge(section)
        else
          { kind: 'field', field: fae_inertia_form_field(item, entry) }.merge(section)
        end
      end
    end

    def fae_inertia_section_block_attrs(entry)
      {
        sectionId: entry[:section_id],
        sectionTitle: entry[:section_title],
        sectionHelperText: entry[:section_helper_text],
        sectionShowTitle: entry[:section_show_title]
      }.compact
    end

    def fae_inertia_subnav_from_fields(fields)
      section_links = []
      seen_targets = {}

      Array(fields).each do |entry|
        title = entry[:section_title].to_s.strip
        target = entry[:section_id].to_s.strip
        next if title.blank? || target.blank?
        next if seen_targets[target]

        section_links << { label: title, target: target }
        seen_targets[target] = true
      end

      section_links
    end

    def fae_inertia_subnav(items)
      Array(items).filter_map do |entry|
        label, target = if entry.is_a?(Array)
                          [entry[0].to_s, entry[1].to_s]
                        else
                          text = entry.to_s
                          [text, text.parameterize(separator: '_')]
                        end

        next if label.blank? || target.blank?

        { label: label, target: target }
      end
    end

    # Association input with related-object flyout defaults, similar in spirit
    # to fae_association but for the Inertia field schema.
    #
    # Example:
    #   fae_flyout_association(:car_category)
    #   fae_flyout_association(:car_category, placeholder: 'Pick one',
    #                          related_flyout: { button_label: 'Add Type' })
    def fae_flyout_association(attribute, **overrides)
      association_name = attribute.to_s.sub(/_id\z/, '')
      field_name = attribute.to_s.end_with?('_id') ? attribute.to_s : "#{association_name}_id"

      related_overrides = fae_inertia_symbolize_hash(overrides.delete(:related_flyout))

      label = overrides[:label] || association_name.to_s.humanize.titleize
      collection = overrides[:collection] || fae_flyout_association_collection(association_name)
      placeholder = overrides[:placeholder] || "Select #{label}"

      field = {
        name: field_name.to_sym,
        type: :select,
        label: label,
        collection: collection,
        placeholder: placeholder,
      }

      default_flyout = {
        title: "New #{label}",
        button_label: "Add #{label}",
        submit_label: "Create #{label}",
        path: fae_flyout_association_quick_create_path(association_name),
        method: 'post',
        param_key: association_name,
        value_key: 'id',
        label_key: 'label',
        fields: fae_flyout_association_fields(association_name)
      }

      field[:related_flyout] = default_flyout.merge(related_overrides)

      # Allow explicit field-level overrides after defaults are assembled.
      field.merge!(overrides.except(:label, :collection, :placeholder))
      field
    end

    def fae_flyout_association_collection(association_name)
      reflection = @klass.reflect_on_association(association_name.to_sym)
      return [] if reflection.blank?

      associated_klass = reflection.klass
      return associated_klass.for_fae_index if associated_klass.respond_to?(:for_fae_index)

      if associated_klass.column_names.include?('position')
        return associated_klass.order(:position)
      end

      if associated_klass.column_names.include?('name')
        return associated_klass.order(:name)
      end

      associated_klass.all
    end

    def fae_flyout_association_fields(association_name)
      controller_klass = "Admin::#{association_name.to_s.pluralize.camelize}Controller".safe_constantize
      return [] unless controller_klass&.respond_to?(:fae_form_fields)

      Array(controller_klass.fae_form_fields).flat_map do |entry|
        Array(entry.dig(:section, :fields))
      end
    end

    def fae_flyout_association_quick_create_path(association_name)
      helper_name = "quick_create_admin_#{association_name.to_s.pluralize}_path"
      return public_send(helper_name) if respond_to?(helper_name)

      nil
    end

    # Supports both legacy flat declarations and grouped section declarations:
    #
    #   [
    #     { section: { title: 'Main', fields: [{ name: :title, type: :text }] } },
    #     { name: :seo_title, type: :text, section_id: 'metadata', section_title: 'Metadata' }
    #   ]
    #
    # Set `show_title: false` on a section to keep its anchor/subnav metadata
    # without rendering a duplicate on-page heading. Useful when the only
    # content in that section is a nested/flex components table, which has its
    # own header.
    #
    # Section ids default from the section title when omitted.
    def fae_inertia_normalize_form_fields(fields)
      Array(fields).flat_map do |raw_entry|
        entry = fae_inertia_symbolize_hash(raw_entry)
        next [] if entry.blank?

        section = fae_inertia_symbolize_hash(entry[:section])
        if section.present?
          section_title = section[:title].to_s.strip.presence
          section_id = section[:id].to_s.strip.presence || section_title&.parameterize(separator: '_')
          section_helper_text = section[:helper_text].to_s.strip.presence
          section_show_title = section.key?(:show_title) ? (section[:show_title] != false) : nil

          Array(section[:fields]).filter_map do |section_field|
            normalized = fae_inertia_symbolize_hash(section_field)
            next if normalized.blank?

            normalized[:section_id] = section_id if section_id.present? && normalized[:section_id].blank?
            normalized[:section_title] = section_title if section_title.present? && normalized[:section_title].blank?
            if section_helper_text.present? && normalized[:section_helper_text].blank?
              normalized[:section_helper_text] = section_helper_text
            end
            if !section_show_title.nil? && normalized[:section_show_title].nil?
              normalized[:section_show_title] = section_show_title
            end
            normalized
          end
        else
          section_title = entry[:section_title].to_s.strip.presence
          if section_title.present? && entry[:section_id].blank?
            entry[:section_id] = section_title.parameterize(separator: '_')
          end
          if entry.key?(:section_show_title)
            entry[:section_show_title] = entry[:section_show_title] != false
          end

          [entry]
        end
      end
    end

    def fae_inertia_symbolize_hash(value)
      return {} unless value.respond_to?(:to_h)

      value.to_h.symbolize_keys
    end

    # Matches the generator, which makes an index sortable when the scaffolded
    # model has a position attribute.
    def fae_inertia_sortable?
      @klass.column_names.include?('position')
    end

    # The :object segment of Fae's sort route, and the key the ids arrive under.
    # Namespaced models double the underscore, mirroring fae_sort_id.
    def fae_inertia_sort_object
      @klass.name.underscore.gsub('/', '__')
    end

    def fae_inertia_index_row(item, keys)
      {
        id: item.id,
        label: item.fae_display_field.to_s,
        editPath: "#{@index_path}/#{item.id}/edit",
        deletePath: "#{@index_path}/#{item.id}",
        cells: keys.index_with { |key| fae_inertia_cell(item, key) }
      }
    end

    def fae_inertia_cell(item, key)
      if fae_inertia_boolean_column?(item, key)
        return {
          kind: 'boolean_toggle',
          value: !!item.public_send(key),
          path: fae.toggle_path(
            item.class.to_s.gsub('::', '__').underscore.pluralize,
            item.id.to_s,
            key
          )
        }
      end

      value = item.public_send(key)

      case value
      when Date, Time, DateTime, ActiveSupport::TimeWithZone
        helpers.fae_date_format(value)
      else
        value.to_s
      end
    end

    def fae_inertia_boolean_column?(item, key)
      item.class.columns_hash[key.to_s]&.type == :boolean
    end

    # Normalizes one field descriptor into props for FaeFormField.
    #
    # `label` defaults the way simple_form's did, off the human attribute name,
    # so a converted form only has to spell out the labels it wants to change.
    # `collection` accepts either [[label, value], ...] or an array of records,
    # matching what fae_association was usually handed.
    def fae_inertia_form_field(item, field)
      name = field[:name].to_s
      type = (field[:type] || :text).to_s
      label = field[:label] || item.class.human_attribute_name(name)
      ranked = (fae_inertia_ranked_select(item, field, name) if type == 'ranked_select')
      related_flyout = fae_inertia_related_flyout(field)

      {
        name: name,
        type: type,
        label: label,
        slugSource: fae_inertia_slug_source?(field),
        hint: field[:hint],
        # The h6.helper_text the Slim label carried. Every field type honours
        # it, not just the ones a fae_* helper happened to expose it on.
        helperText: field[:helper_text],
        translate: field.fetch(:translate, true),
        required: field.fetch(:required) { fae_inertia_required?(item, name) },
        value: fae_inertia_field_value(item, name, type, ranked),
        # Opts a textarea into the markdown editor, as `fae_input ... markdown: true` did.
        markdown: field[:markdown].presence,
        placeholder: field[:placeholder],
        relatedFlyout: related_flyout,
        collection: (type == 'ranked_select' ? fae_inertia_ranked_collection(field, name) : fae_inertia_collection(field[:collection]) if %w[select multiselect ranked_select].include?(type)),
        ranked: ranked,
        asset: (fae_inertia_asset(item, field, name, type, label) if ASSET_FIELD_TYPES.include?(type))
      }.compact
    end

    def fae_inertia_related_flyout(field)
      config = fae_inertia_symbolize_hash(field[:related_flyout])
      return nil if config.blank? || config[:path].blank?

      related_klass = fae_inertia_related_flyout_class(config)
      related_item = related_klass&.new

      fields = Array(config[:fields]).filter_map do |raw|
        entry = fae_inertia_symbolize_hash(raw)
        next if entry.blank? || entry[:name].blank?

        name = entry[:name].to_s
        type = (entry[:type] || :text).to_s
        label = (entry[:label] || name.humanize).to_s

        if related_item.present? && ASSET_FIELD_TYPES.include?(type)
          builder = "build_#{name}"
          related_item.public_send(builder) if related_item.respond_to?(builder) && related_item.public_send(name).blank?
        end

        {
          name: name,
          type: type,
          label: label,
          slugSource: fae_inertia_slug_source?(entry),
          hint: entry[:hint],
          helperText: entry[:helper_text],
          required: if entry.key?(:required)
                      entry[:required] == true
                    elsif related_item.present?
                      fae_inertia_required?(related_item, name)
                    else
                      false
                    end,
          value: (related_item.present? ? fae_inertia_field_value(related_item, name, type) : nil),
          placeholder: entry[:placeholder],
          collection: (fae_inertia_collection(entry[:collection]) if %w[select multiselect].include?(type)),
          asset: (fae_inertia_asset(related_item, entry, name, type, label) if related_item.present? && ASSET_FIELD_TYPES.include?(type))
        }.compact
      end

      {
        title: config[:title].to_s.presence || 'Create Item',
        buttonLabel: config[:button_label].to_s.presence || 'Add',
        submitLabel: config[:submit_label].to_s.presence || 'Create',
        path: config[:path].to_s,
        method: config[:method].to_s.presence || 'post',
        paramKey: config[:param_key].to_s.presence || 'item',
        valueKey: config[:value_key].to_s.presence || 'id',
        labelKey: config[:label_key].to_s.presence || 'label',
        fields: fields
      }
    end

    def fae_inertia_related_flyout_class(config)
      explicit = config[:model_class].to_s.strip
      klass = explicit.present? ? explicit.safe_constantize : nil
      return klass if klass.present?

      key = config[:param_key].to_s.strip
      return nil if key.blank?

      key.classify.safe_constantize
    end

    def fae_inertia_slug_source?(field)
      input_class = field[:input_class].to_s
      return true if input_class.split(/\s+/).include?('slugger')

      field[:slug_source] == true
    end

    # Whether the label gets an asterisk. simple_form derived this from the
    # model's validators, so a Slim form never restated it; `required:` on a
    # descriptor is an override for what no validator covers -- an asset
    # field's requirement is a column on the Fae::Image/Fae::File, not a
    # validation on the parent.
    def fae_inertia_required?(item, name)
      klass = item.class
      return false unless klass.respond_to?(:validators_on)

      # A belongs_to declares its presence validator on the association, while
      # the field is the foreign key.
      association = klass.reflect_on_all_associations(:belongs_to)
                         .find { |reflection| reflection.foreign_key.to_s == name }

      [name, association&.name].compact.any? do |attribute|
        klass.validators_on(attribute).any? do |validator|
          next false unless validator.kind == :presence
          # A conditional validator cannot be resolved without running it.
          next false if validator.options.key?(:if) || validator.options.key?(:unless)

          case validator.options[:on]
          when nil, :save then true
          when :create then !item.persisted?
          when :update then item.persisted?
          else false
          end
        end
      end
    end

    def fae_inertia_field_value(item, name, type, ranked = nil)
      return fae_inertia_asset_value(item, name, type) if ASSET_FIELD_TYPES.include?(type)

      if type == 'ranked_select'
        return Array(ranked&.dig(:rows)).map { |row| row[:associatedId].to_s }
      end

      if type == 'multiselect'
        values = item.public_send(name)
        return Array(values).map { |entry| entry.respond_to?(:id) ? entry.id : entry }.map(&:to_s)
      end

      value = item.public_send(name)

      if %w[date datepicker].include?(type)
        return '' if value.blank?

        return value.to_date.iso8601 if value.respond_to?(:to_date)

        begin
          return Date.parse(value.to_s).iso8601
        rescue ArgumentError, TypeError
          return value.to_s
        end
      end

      if type == 'datetime-local'
        return '' if value.blank?

        return value.strftime('%Y-%m-%dT%H:%M') if value.respond_to?(:strftime)

        return value.to_s
      end

      # Static-page text fields are has_one Fae::TextField/Fae::TextArea
      # objects; the form input needs their content, not object inspect.
      if %w[text textarea].include?(type) && value.respond_to?(:content)
        return value.content.to_s
      end

      # Everything but a checkbox round-trips as a string: a <select> matches
      # its options by string value, and Rails casts on the way back in, so
      # keeping one representation avoids a nil id selecting the first option.
      type == 'checkbox' ? !!value : value.to_s
    end

    # The editable half of an asset field -- what gets submitted back as
    # <name>_attributes. `asset` is filled in client-side with the chosen File;
    # null means "leave whatever is stored alone", which is how the Slim form's
    # empty file input behaved.
    def fae_inertia_asset_value(item, name, type)
      record = item.public_send(name)

      value = { id: record&.id, asset: nil }
      value.merge!(alt: record&.alt.to_s, caption: record&.caption.to_s) if type == 'image'
      value
    end

    # The read-only half: the current attachment plus everything the uploader
    # needs to police an upload before it is sent.
    def fae_inertia_asset(item, field, name, type, label)
      image = type == 'image'
      record = item.public_send(name)
      limit = image ? Fae.max_image_upload_size : Fae.max_file_upload_size

      {
        kind: type,
        # has_fae_image/has_fae_file declare accepts_nested_attributes_for, so
        # the asset saves with its parent rather than through its own request.
        paramKey: "#{name}_attributes",
        maxSize: limit,
        # ### is the placeholder the shared locale string uses for the limit.
        maxSizeMessage: t('fae.exceeded_upload_limit').sub('###', limit.to_s),
        accept: fae_inertia_asset_accept(record),
        deleteConfirmation: t('fae.delete_confirmation'),
        canGenerateAlt: image && Fae.open_ai_api_key.present?,
        generateAltPath: (fae.generate_alt_path if image && Fae.open_ai_api_key.present?),
        showAlt: image && field.fetch(:show_alt, true),
        showCaption: image && field.fetch(:show_caption, false),
        altLabel: field[:alt_label] || "#{label} Alt Text",
        captionLabel: field[:caption_label] || "#{label} Caption",
        altHelperText: field.fetch(:alt_helper_text) { t('fae.images.alt_helper') },
        captionHelperText: field[:caption_helper_text],
        current: fae_inertia_stored_asset(record, image)
      }.compact
    end

    def fae_inertia_stored_asset(record, image)
      return nil if record.blank? || record.asset.blank?

      {
        id: record.id,
        url: record.asset.url,
        # Deleting only strips the asset, keeping the row, so re-uploading
        # updates the same record -- see Fae::ImagesController#delete_image.
        deletePath: (image ? fae.delete_image_path(record.id) : fae.delete_file_path(record.id)),
        thumbUrl: (record.asset.thumb.url if image && record.asset.thumb.present?),
        filename: record.asset.file&.filename
      }.compact
    end

    def fae_inertia_ranked_select(item, field, name)
      join_assoc = field[:join_model].to_s
      raise ArgumentError, "ranked_select requires join_model for #{name}" if join_assoc.blank?

      join_records = Array(item.public_send(join_assoc)).sort_by { |record| record.try(:position).to_i }
      associated_name = (field[:association] || name.to_s.sub(/_ids$/, '').pluralize).to_s.singularize
      join_model = join_assoc.classify

      parent_model = if item.class.superclass.name == 'Fae::StaticPage'
                       'StaticPage'
                     else
                       item.class.name
                     end

      sort_object = join_model.underscore.pluralize.gsub('/', '__')

      {
        parentModel: parent_model,
        parentId: item.id,
        joinModel: join_model,
        associatedModel: associated_name.classify,
        rankedItemPath: fae.ranked_item_path,
        sortPath: fae.sort_path(sort_object),
        sortObject: sort_object,
        rankingTitle: field[:ranking_title] || "#{name.titleize} Ranking",
        rankingHelperText: field[:ranking_helper_text],
        rows: join_records.filter_map do |record|
          associated = record.public_send(associated_name)
          next if associated.blank?

          {
            id: record.id,
            associatedId: associated.id,
            label: associated.public_send(field[:display_field] || :fae_display_field).to_s,
            previewImageUrl: (fae_inertia_ranked_preview(associated, field[:preview_image]) if field[:preview_image].present?)
          }
        end
      }
    end

    def fae_inertia_ranked_collection(field, name)
      collection = field[:collection]
      assoc_name = (field[:association] || name.to_s.sub(/_ids$/, '').pluralize).to_s

      if collection.blank?
        # Static page controllers include this concern but do not set @klass.
        source_klass = @klass || @item&.class
        reflection = source_klass&.reflect_on_association(assoc_name.to_sym)
        collection = reflection&.klass&.respond_to?(:for_fae_index) ? reflection.klass.for_fae_index : []
      end

      Array(collection).map do |record|
        next if record.blank?

        preview = if field[:preview_image].present? && record.respond_to?(field[:preview_image])
                    fae_inertia_ranked_preview(record, field[:preview_image])
                  end

        {
          label: record.respond_to?(:fae_display_field) ? record.fae_display_field.to_s : record.to_s,
          value: record.respond_to?(:id) ? record.id : record,
          previewImageUrl: preview
        }
      end.compact
    end

    def fae_inertia_ranked_preview(record, preview_field)
      image = record.public_send(preview_field)
      return nil if image.blank? || image.asset.blank?

      image.asset.try(:thumb).try(:url) || image.asset.url
    end

    # Read off the mounted uploader rather than hardcoded, so an app that
    # overrides Fae::ImageUploader gets its own allowlist in the file picker.
    def fae_inertia_asset_accept(record)
      extensions = record.try(:asset).try(:extension_allowlist)
      return nil if extensions.blank?

      extensions.map { |extension| ".#{extension}" }.join(',')
    end

    def fae_inertia_collection(collection)
      Array(collection).map do |option|
        if option.is_a?(Array)
          { label: option[0].to_s, value: option[1] }
        elsif option.respond_to?(:fae_display_field)
          { label: option.fae_display_field.to_s, value: option.id }
        else
          { label: option.to_s, value: option }
        end
      end
    end

    # Serializes one has_many table for the parent's form -- the Vue
    # counterpart of fae/shared/_nested_table.
    #
    # Everything a row's form needs travels with the page, so revealing it is
    # instant rather than the GET-and-splice form/_ajax.js had to do. The rows
    # are small (a nested table lists a handful of columns) and it removes the
    # entire class of bugs that came from injecting server-rendered markup into
    # a live form.
    def fae_inertia_nested_table(parent, table, draft = false)
      assoc = table[:nested_table].to_s
      records = parent.public_send(assoc)
      klass = records.klass
      cols = Array(table[:cols])
      fields = table[:fields] || fae_inertia_nested_controller(assoc).fae_form_fields
      fields = fae_inertia_normalize_form_fields(fields)
      title = table[:title] || assoc.titleize

      # Nested resources are routed as siblings of the parent, which is what
      # _nested_table assumed too when it derived new_/edit_#{assoc}_path.
      base_path = "#{@index_path.rpartition('/').first}/#{assoc}"
      # Carried so a save on a draft parent redirects back to a form that still
      # knows it is a draft.
      query = draft ? '?draft=true' : ''

      {
        title: title,
        addButtonText: table[:add_button_text] || t('fae.common.add', title: title.singularize),
        helperText: table[:helper_text],
        hideAddButton: table.fetch(:hide_add_button, false),
        hideDeleteButton: table.fetch(:hide_delete_button, false),
        openRowId: (params[:open_nested_assoc] == assoc && params[:open_nested_row_id].present? ? params[:open_nested_row_id].to_i : nil),
        openNewRow: (params[:open_nested_assoc] == assoc && params[:open_nested_new] == 'true'),
        paramKey: assoc.singularize,
        # Names the Inertia error bag for this table, so a failed nested save
        # cannot light up the parent form's fields (or a sibling table's).
        errorBag: assoc.singularize,
        createPath: "#{base_path}#{query}",
        columns: cols.map { |col| { key: col.to_s, label: klass.human_attribute_name(col) } },
        # The association column, sent with every save the way the hidden
        # field in the Slim nested form did.
        parentKey: parent.class.reflect_on_association(assoc).foreign_key.to_s,
        parentId: parent.id,
        extraHidden: fae_inertia_nested_hidden_fields(parent, assoc),
        newFields: fields.map { |field| fae_inertia_form_field(klass.new, field) },
        rows: records.map do |record|
          {
            id: record.id,
            label: record.fae_display_field.to_s,
            path: "#{base_path}/#{record.id}#{query}",
            cells: cols.index_with { |col| fae_inertia_nested_cell(record, col) },
            fields: fields.map { |field| fae_inertia_form_field(record, field) }
          }
        end
      }
    end

    def fae_inertia_nested_cell(record, column)
      value = record.public_send(column)

      if value.respond_to?(:asset)
        asset = value.asset
        return { kind: 'text', text: '' } if asset.blank?

        url = asset.try(:url, :thumb) || asset.try(:thumb).try(:url) || asset.url
        return { kind: 'image', url: url, text: '' } if url.present?

        return { kind: 'text', text: '' }
      end

      { kind: 'text', text: fae_inertia_cell(record, column) }
    end

    # Polymorphic children need both *_id and *_type to resolve the parent.
    def fae_inertia_nested_hidden_fields(parent, assoc)
      reflection = parent.class.reflect_on_association(assoc)
      return {} unless reflection.present? && reflection.polymorphic?

      { reflection.type.to_s => parent.class.name }
    end

    def fae_inertia_flex_components_table(parent, table, draft = false)
      assoc = (table[:flex_components_table] || :flex_components).to_s
      title = table[:title] || assoc.titleize
      records = parent.public_send(assoc)

      item_class = if parent.class.ancestors.include?(Fae::StaticPage)
                     'Fae::StaticPage'
                   else
                     parent.class.name
                   end

      query = draft ? '?draft=true' : ''
      component_options = Fae::FlexComponent.components_for(item_class).map do |label, value|
        { label: label, value: value }
      end

      {
        title: title,
        helperText: table[:helper_text],
        createPath: fae.flex_components_path,
        createParams: {
          flex_componentable_type: item_class,
          flex_componentable_id: parent.id
        },
        sortPath: fae.sort_path('fae__flex_components'),
        sortParam: 'fae__flex_components',
        componentOptions: component_options,
        openRowId: params[:open_flex_component_id].present? ? params[:open_flex_component_id].to_i : nil,
        rows: records.map { |record| fae_inertia_flex_component_row(record, query) }
      }
    end

    def fae_inertia_flex_component_row(record, query = '')
      component = record.component_instance
      controller = fae_inertia_flex_component_controller(component)
      fields = controller&.respond_to?(:fae_form_fields) ? controller.fae_form_fields : []
      fields = fae_inertia_normalize_form_fields(fields)
      namespace = self.class.name.deconstantize.underscore

      component_path = if component.present?
                         "/#{namespace}/#{component.class.name.underscore.pluralize}/#{component.id}#{query}"
                       end

      {
        id: record.id,
        label: record.component_model_human.to_s,
        preview: record.fae_display_field.to_s,
        imageUrl: record.preview_image_url,
        onStage: !!record.on_stage,
        onProd: !!record.on_prod,
        onStageTogglePath: fae.toggle_path(record.class.to_s.gsub('::', '__').underscore.pluralize, record.id.to_s, :on_stage),
        onProdTogglePath: fae.toggle_path(record.class.to_s.gsub('::', '__').underscore.pluralize, record.id.to_s, :on_prod),
        deletePath: fae.flex_component_path(record),
        editPath: component_path,
        form: (
          if component.present? && fields.any?
            {
              action: component_path,
              method: 'put',
              paramKey: component.model_name.param_key,
              errorBag: component.model_name.param_key,
              fields: fields.map { |field| fae_inertia_form_field(component, field) },
              tables: fae_inertia_flex_component_tables(component, controller)
            }
          end
        )
      }.compact
    end

    def fae_inertia_flex_component_tables(component, controller)
      return [] unless controller&.respond_to?(:fae_nested_tables)

      Array(controller.fae_nested_tables).filter_map do |table|
        next unless table[:nested_table].present?

        fae_inertia_nested_table(component, table, params[:draft] == 'true')
      end
    end

    def fae_inertia_flex_component_controller(component)
      return nil if component.blank?

      controller_name = component.class.name.underscore.pluralize.camelize
      "#{self.class.name.deconstantize}::#{controller_name}Controller".safe_constantize
    end

    # The nested resource's own controller declares its form fields, so a table
    # is described by nothing more than its association name -- the same
    # convention _nested_table used to derive its paths.
    def fae_inertia_nested_controller(assoc)
      "#{self.class.name.deconstantize}::#{assoc.camelize}Controller".constantize
    end
  end
end
