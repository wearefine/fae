module Fae
  # Opt-in for rendering a Fae screen with Inertia + Vue instead of Slim.
  #
  # Fae 5 will fold this into Fae::BaseController, but keeping it as a concern
  # during the migration lets converted and unconverted screens coexist in the
  # same app.
  module InertiaRenderable
    extend ActiveSupport::Concern

    included do
      inertia_config layout: 'fae/inertia'

      inertia_share do
        {
          currentUser: fae_inertia_current_user,
          flash: { notice: flash[:notice], alert: flash[:alert] }.compact,
          nav: fae_inertia_nav
        }
      end
    end

    private

    def fae_inertia_current_user
      return nil if current_user.blank?

      { id: current_user.id, name: current_user.try(:fae_display_field).to_s }
    end

    # @fae_topnav_items is built by ApplicationController#build_nav.
    def fae_inertia_nav
      Array(@fae_topnav_items).map do |item|
        { title: item[:text], path: item[:path] }
      end
    end

    # Renders the generic Fae index. Mirrors Fae::BaseController#index, which is
    # itself model-agnostic, so the Vue page is driven purely by props.
    #
    #   render_fae_index(@klass.for_fae_index, columns: { name: 'Name' })
    def render_fae_index(items, columns:)
      render inertia: 'Fae/Index', props: {
        title: @klass_humanized.pluralize.titleize,
        newPath: @new_path,
        columns: columns.map { |key, label| { key: key.to_s, label: label } },
        rows: items.map { |item| fae_inertia_index_row(item, columns.keys) }
      }
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
  end
end
