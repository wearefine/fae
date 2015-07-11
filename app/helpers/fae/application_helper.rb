module Fae
  module ApplicationHelper

    def form_header(name)
      name = name.class.name.split('::').last unless name.is_a? String
      form_title = "#{params[:action]} #{name}".titleize
      form_title = form_title.singularize if params[:action] == 'edit'
      content_tag :h1, form_title
    end

    def markdown_helper(links: true, formatting: true, emphasis: true, headers: true, list: true, paragraph: true)
      helper = "<h3>Markdown Options</h3>"
      helper += "<h4>Links</h4>
            <p>
              To link text, place a [bracket] around the link title and use a (/url) to house the url.<br>
              <br>
              Internal Link: [link to about](/about)<br>
              External link: [link to about](http://www.google.com/about)
            </p>" if links
      helper += "<h4>Formatting</h4>
            <p>
              Emphasize text in a variety of ways by placing **asterisks** to bold, _underscores_ to italicize.<br>
              <br>
              Bold  **bold**<br>
              Italicize _italic_
            </p>" if formatting || emphasis
      helper += "<h4>Headers</h4>
            <p>
              Use up to six hashtags to identify the importance of the section header.<br>
              <br>
              Page Header: # Page Header<br>
              Sub Header: ## Sub Header
            </p>" if headers
      helper += "<h4>List</h4>
            <p>
              Format lists by swapping out the characters that lead the list item.</br>
              <br>
              <span>Bulleted List:</span><br>
              * bullet<br>
              * bullet 2<br>
              <br>
              <span>Numbered List:</span><br>
              1. line item<br>
              2. line item
            </p>" if list
      helper += "<h4>Paragraph Break</h4>
            <p>
              Adding a blank line in between your paragraphs makes a paragraph break.
            </p>" if paragraph
      helper.html_safe
    end

    def require_locals(local_array, local_assigns)
      local_array.each do |loc|
        raise "#{loc} is a required local, please define it when you render this partial" unless local_assigns[loc.to_sym].present?
      end
    end

    def col_name_or_image(item, attribute)
      # if item's attribute is an association
      if item.class.reflections.include?(attribute)
        if item.send(attribute).class.name == 'Fae::Image'
          # display image thumbnail
          image_tag(item.send(attribute).asset.thumb.url)
        else
          # display associaiton's fae_display_field
          item.send(attribute).fae_display_field
        end
      # if item is a date or a time adjust to timezone
      elsif item.send(attribute).kind_of?(Date)
        fae_date_format(item.send(attribute))
      elsif item.send(attribute).kind_of?(Time)
        fae_datetime_format(item.send(attribute))
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

    def body_class
      @body_class.present? ? @body_class : "#{controller_name} #{action_name}"
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

  end
end
