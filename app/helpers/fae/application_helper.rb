module Fae
  module ApplicationHelper

    def form_header(name)
      name = name.class.name.split('::').last unless name.is_a? String
      form_title = "#{params[:action]} #{name}".titleize
      form_title = form_title.singularize if params[:action] == 'edit'
      content_tag :h1, form_title
    end

    def require_locals(local_array, local_assigns)
      local_array.each do |loc|
        raise "#{loc} is a required local, please define it when you render this partial" unless local_assigns[loc.to_sym].present?
      end
    end

    def nav_active_class(klass, level, idx, parent_idx = nil)
      return klass unless @fae_navigation.coordinates[level] == idx
      return klass unless parent_idx.blank? || @fae_navigation.coordinates[level-1] == parent_idx
      new_klass = parent_idx.blank? ? '-parent-current -open' : '-current'
      new_klass += " #{klass}" if klass.present?
      new_klass
    end

    def deployments_active_class
      '-parent-current -open' if params[:controller].split('/').last == 'deploy'
    end

    def col_name_or_image(item, attribute)
      value = item.send(attribute)
      return if value.blank?
      # if item is an image
      if value.class.name == 'Fae::Image'
        image_tag(value.asset.thumb.url) if value.asset.thumb.url.present?
      # if item's attribute is an association
      elsif item.class.reflections.include?(attribute)
        value.try(:fae_display_field)
      # if item is a date or a time adjust to timezone
      elsif value.is_a?(Date) || value.is_a?(ActiveSupport::TimeWithZone)
        fae_date_format(value)
      elsif value.is_a?(Time)
        fae_datetime_format(value)
      else
        # otherwise it's an attribute so display it's value
        value
      end
    end

    def fae_scope
      fae.root_path.gsub('/', '')
    end

    def page_title
      if @page_title.present?
        @page_title
      else
        default_page_title
      end
    end

    def body_class
      @body_class.present? ? @body_class : "#{controller_name} #{action_name}"
    end

    def change_item_link(change)
      text = "#{change.changeable_type.gsub('Fae::','')}: "
      test_source_method = :data_source_exists?

      if change.changeable_type.exclude?('Fae') && change.changeable_type.exclude?('Page') && !ActiveRecord::Base.connection.send(test_source_method, change.changeable_type.tableize)
        return "#{change.changeable_type}: model destroyed"
      else
        display_text = change.try(:changeable).try(:fae_display_field)
        display_text = (display_text.is_a? Integer) ? display_text.to_s : display_text
        text += display_text || "##{change.changeable_id}"

        begin
          return link_to text, fae.edit_content_block_path(change.changeable.slug) if change.changeable_type == 'Fae::StaticPage'
          parent = change.changeable.respond_to?(:fae_parent) ? change.changeable.fae_parent : nil
          edit_path = edit_polymorphic_path(
            [main_app, fae_scope.to_sym, parent, change.changeable]
          )
          return link_to text, edit_path
        rescue
          return text
        end
      end
    end

    def netlify_enabled?
      Fae.netlify.present? &&
      Fae.netlify[:api_user].present? &&
      Fae.netlify[:api_token].present? &&
      Fae.netlify[:site].present? &&
      Fae.netlify[:site_id].present? &&
      Fae.netlify[:api_base].present?
    end

    private

    def nav_path_current?(path)
      current_page?(path) || path[1..-1].classify == params[:controller].classify
    end

    def default_page_title
      pieces = [@option.title]
      pieces << page_title_piece
      pieces.join ' | '
    end

    def page_title_piece
      return @page_title_piece if @page_title_piece.present?

      action = params[:action].humanize.titleize unless params[:action] == 'index'
      controller = controller_title unless params[:controller] == 'fae/pages'
      controller = controller.singularize if params[:action] == 'new' || params[:action] == 'edit'

      "#{action} #{controller}".strip
    end

    def controller_title
      params[:controller].gsub(/fae\/|#{fae_scope}\//, '').humanize.titleize
    end

    def tr_id(item)
      "#{item.class.name.underscore.gsub('/', '_').pluralize}_#{item.id}"
    end

    def multi_column_nav_ul_class(item_count)
      num = item_count.length
      if num > 30
        'multicol-nav four'
      elsif num > 20
        'multicol-nav three'
      elsif num > 10
        'multicol-nav'
      end
    end
  end
end
