module Fae
  # Inertia counterpart of Fae::NestedBaseController's write actions.
  #
  # The Slim flow answered every write by re-rendering the association's table
  # partial and letting form/_ajax.js splice the HTML back into the open page.
  # Inertia has no equivalent, and needs none: redirecting to the parent's form
  # re-renders that whole screen from fresh props, nested rows included, while
  # the page component stays mounted so the parent's unsaved input survives.
  #
  # Every action falls through to super for a non-Inertia request, so a
  # resource can be reached from a converted parent form and an unconverted
  # Slim one at the same time.
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
      return super unless request.inertia?

      @item = @klass.new(permitted_params)
      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.save
        redirect_to fae_inertia_parent_path(@item), notice: t('fae.save_notice')
      else
        fae_inertia_redirect_with_errors(@item)
      end
    end

    def update
      return super unless request.inertia?

      raise_undefined_parent if @item.fae_nested_parent.blank?

      if @item.update(permitted_params)
        redirect_to fae_inertia_parent_path(@item), notice: t('fae.save_notice')
      else
        fae_inertia_redirect_with_errors(@item)
      end
    end

    def destroy
      return super unless request.inertia?

      raise_undefined_parent if @item.fae_nested_parent.blank?

      # Resolved before the row goes away, or there would be nothing left to
      # derive the parent's path from.
      path = fae_inertia_parent_path(@item)

      if @item.destroy
        redirect_to path, notice: t('fae.delete_notice')
      else
        redirect_to path, flash: { error: t('fae.delete_error') }
      end
    end

    private

    def fae_inertia_redirect_with_errors(item)
      redirect_to fae_inertia_parent_path(item),
                  inertia: { errors: fae_inertia_scoped_errors(item) },
                  flash: { alert: t('fae.save_error') }
    end

    # Where a write returns to: the form of the record this one hangs off.
    # Built from the association rather than from anything the client sent, so
    # there is no redirect target to tamper with.
    def fae_inertia_parent_path(item)
      parent = item.public_send(item.fae_nested_parent)
      # Only reachable when the foreign key was missing, which is itself a
      # validation error -- there is no parent form to go back to.
      return fae.root_path if parent.blank?

      namespace = params[:controller].rpartition('/').first
      path = "/#{namespace}/#{parent.class.name.underscore.pluralize}/#{parent.id}/edit"
      # The parent may still be a draft, and losing the flag would stop its
      # Cancel button from deleting the record #new created.
      path += '?draft=true' if params[:draft] == 'true'
      path
    end
  end
end
