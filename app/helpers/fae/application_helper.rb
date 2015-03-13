module Fae
  module ApplicationHelper

    def form_header(name)
      name = name.class.name.split('::').last unless name.is_a? String
      form_title = "#{params[:action]} #{name}".titleize
      form_title = form_title.singularize if params[:action] == 'edit'
      content_tag :h1, form_title
    end

    def markdown_helper(headers: true, emphasis: true)
      helper = "<h3>Markdown Options</h3>
            <p>
              Link | Internal: See my [About](/about/) page for details.<br>
              Link | External: This is [an example](http://example.com/ \"Title\") inline link.<br>
              List | Bullets: add an asterick with a space before the text, eg: * this will have bullets<br>
              List | Numbered: Numbers with a period and a space before the text, eg: 1. this will be item 1
            </p>"
      helper += "<h3>Emphasis</h3>
            <p>
              Add italics with _underscores_<br>
              Add bold with double **asterisks**<br>
              Add combined emphasis with **asterisks and _underscores_**
            </p>" if emphasis
      helper += "<h3>Headers</h3>
            <p>
              ##### H5 text<br>
              ###### H6 text
            </p>" if headers
      helper.html_safe
    end

    def require_locals(local_array, local_assigns)
      local_array.each do |loc|
        raise "#{loc} is a required local, please define it when you render this partial" unless local_assigns[loc.to_sym].present?
      end
    end

    def col_name(item, attribute)
      # if item's attribute is an association
      if item.class.reflections.include?(attribute)
        # display associaiton's fae_display_field
        item.send(attribute).fae_display_field
      else
        # otherwise it's an attribute so display it's value
        item.send(attribute)
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

  end
end
