module Fae
  # Opt-in for rendering a Fae screen with Inertia + Vue instead of Slim.
  #
  # Fae 5 will fold this into Fae::BaseController, but keeping it as a concern
  # during the migration lets converted and unconverted screens coexist in the
  # same app.
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
          currentUser: fae_inertia_current_user,
          flash: fae_inertia_flash,
          nav: fae_inertia_nav
        }
      end
    end

    # The write actions below only diverge from Fae::BaseController when the
    # request actually came from Inertia. A controller can therefore have a Vue
    # index and a Slim form at the same time -- the Slim form posts a normal
    # HTML request and falls straight through to super. That is the state
    # article_categories is in, and it must keep working.

    def create
      return super unless request.inertia?
      return super if params[:from_existing].present?

      @item = @klass.new(item_params)

      if @item.save
        redirect_to @index_path, notice: t('fae.save_notice')
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
      return super unless request.inertia?

      @item.draft = false if @klass.has_fae_draft_support?

      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
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
    def render_fae_form(item = @item, fields:, title: nil)
      # Fae::BaseController#new saves the record before redirecting here, so
      # "new" is really an edit of an unsaved-looking row. The draft flag is
      # what tells the Vue form that cancelling should delete it again.
      draft = params[:draft] == 'true'

      # The flag has to survive the round trip: it lives only in the query
      # string, and a failed save redirects back here off the submit URL.
      submit_path = item.persisted? ? "#{@index_path}/#{item.id}" : @index_path
      submit_path += '?draft=true' if draft

      render inertia: 'Fae/Form', props: {
        title: title || "#{draft ? 'New' : 'Edit'} #{@klass_humanized}".titleize,
        indexPath: @index_path,
        # Both verbs are supported so this still works for a model that opts
        # out of the draft-on-new behaviour by overriding #new.
        submitPath: submit_path,
        submitMethod: item.persisted? ? 'put' : 'post',
        paramKey: @klass_singular,
        blocks: fae_inertia_form_blocks(item, fields, draft),
        draft: draft,
        deletePath: (item.persisted? ? "#{@index_path}/#{item.id}" : nil)
      }
    end

    # Flattens the form's declaration into an ordered list the page renders
    # top to bottom, so a nested table keeps its position among the inputs.
    def fae_inertia_form_blocks(item, fields, draft)
      fields.filter_map do |entry|
        if entry[:nested_table].present?
          # An unsaved parent has nothing to hang children off, the same reason
          # the Slim form wrapped its nested tables in `if @item.persisted?`.
          next unless item.persisted?

          { kind: 'nestedTable', table: fae_inertia_nested_table(item, entry, draft) }
        else
          { kind: 'field', field: fae_inertia_form_field(item, entry) }
        end
      end
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
      value = item.public_send(key)

      case value
      when Time, DateTime, ActiveSupport::TimeWithZone
        helpers.fae_date_format(value)
      else
        value.to_s
      end
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

      {
        name: name,
        type: type,
        label: label,
        hint: field[:hint],
        # The h6.helper_text the Slim label carried. Every field type honours
        # it, not just the ones a fae_* helper happened to expose it on.
        helperText: field[:helper_text],
        required: field.fetch(:required) { fae_inertia_required?(item, name) },
        value: fae_inertia_field_value(item, name, type),
        # Opts a textarea into the markdown editor, as `fae_input ... markdown: true` did.
        markdown: field[:markdown].presence,
        collection: (fae_inertia_collection(field[:collection]) if type == 'select'),
        asset: (fae_inertia_asset(item, field, name, type, label) if ASSET_FIELD_TYPES.include?(type))
      }.compact
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

    def fae_inertia_field_value(item, name, type)
      return fae_inertia_asset_value(item, name, type) if ASSET_FIELD_TYPES.include?(type)

      value = item.public_send(name)

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
        url: record.asset.url,
        # Deleting only strips the asset, keeping the row, so re-uploading
        # updates the same record -- see Fae::ImagesController#delete_image.
        deletePath: (image ? fae.delete_image_path(record.id) : fae.delete_file_path(record.id)),
        thumbUrl: (record.asset.thumb.url if image && record.asset.thumb.present?),
        filename: record.asset.file&.filename
      }.compact
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
        newFields: fields.map { |field| fae_inertia_form_field(klass.new, field) },
        rows: records.map do |record|
          {
            id: record.id,
            label: record.fae_display_field.to_s,
            path: "#{base_path}/#{record.id}#{query}",
            cells: cols.index_with { |col| fae_inertia_cell(record, col) },
            fields: fields.map { |field| fae_inertia_form_field(record, field) }
          }
        end
      }
    end

    # The nested resource's own controller declares its form fields, so a table
    # is described by nothing more than its association name -- the same
    # convention _nested_table used to derive its paths.
    def fae_inertia_nested_controller(assoc)
      "#{self.class.name.deconstantize}::#{assoc.camelize}Controller".constantize
    end
  end
end
