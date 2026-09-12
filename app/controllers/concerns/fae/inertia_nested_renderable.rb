module Fae
  # Inertia counterpart of Fae::NestedBaseController's write actions.
  #
  # The Slim flow answered every write by re-rendering the association's table
  # partial and letting form/_ajax.js splice the HTML back into the open page.
  # Inertia has no equivalent, and needs none: redirecting to the parent's form
  # re-renders that whole screen from fresh props, nested rows included, while
  # the page component stays mounted so the parent's unsaved input survives.
  #
  module InertiaNestedRenderable
    extend ActiveSupport::Concern
    include Fae::InertiaErrors

    class_methods do
      # Field descriptors for this resource's form, in the shape
      # render_fae_form takes. Declared on the class rather than as an instance
      # method because the parent's nested table reads them without ever
      # instantiating this controller.
      def fae_form_fields
        []
      end
    end

    def create
      @item = @klass.new(permitted_params)
      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.save
        redirect_to fae_inertia_parent_path(@item, open_row: false), notice: t('fae.save_notice')
      else
        fae_inertia_redirect_with_errors(@item)
      end
    end

    def update
      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.update(permitted_params)
        redirect_to fae_inertia_parent_path(@item, open_row: false), notice: t('fae.save_notice')
      else
        fae_inertia_redirect_with_errors(@item)
      end
    end

    def destroy
      raise_undefined_parent if @item.fae_nested_parent.blank?

      # Resolved before the row goes away, or there would be nothing left to
      # derive the parent's path from.
      path = fae_inertia_parent_path(@item, open_row: false)

      if @item.destroy
        redirect_to path, notice: t('fae.delete_notice')
      else
        redirect_to path, flash: { error: t('fae.delete_error') }
      end
    end

    private

    def fae_inertia_redirect_with_errors(item)
      redirect_to fae_inertia_parent_path(item, open_row: true),
                  inertia: { errors: fae_inertia_scoped_errors(item) },
                  flash: { alert: t('fae.save_error') }
    end

    # Where a write returns to: the form of the record this one hangs off.
    # Built from the association rather than from anything the client sent, so
    # there is no redirect target to tamper with.
    def fae_inertia_parent_path(item, open_row: false)
      parent = item.public_send(item.fae_nested_parent)
      # Only reachable when the foreign key was missing, which is itself a
      # validation error -- there is no parent form to go back to.
      return fae.root_path if parent.blank?

      namespace = params[:controller].rpartition('/').first
      parent_segment = parent.class.name.demodulize.underscore.pluralize
      namespace_prefix = if namespace == 'fae'
                           fae.root_path.to_s.chomp('/')
                         else
                           "/#{namespace}"
                         end
      path = "#{namespace_prefix}/#{parent_segment}/#{parent.id}/edit"
      query = {}
      # The parent may still be a draft, and losing the flag would stop its
      # Cancel button from deleting the record #new created.
      query[:draft] = true if params[:draft] == 'true'

      if open_row
        association = item.respond_to?(:association_type) ? item.association_type : nil
        query[:open_nested_assoc] = association.presence || item.class.name.demodulize.underscore.pluralize
        query[:open_nested_row_id] = item.id if item.persisted?
      end

      path += "?#{query.to_query}" if query.present?
      path
    end
  end
end
