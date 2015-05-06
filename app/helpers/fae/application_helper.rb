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

    def us_states
      {
        AL: 'Alabama',
        AK: 'Alaska',
        AS: 'America Samoa',
        AZ: 'Arizona',
        AR: 'Arkansas',
        CA: 'California',
        CO: 'Colorado',
        CT: 'Connecticut',
        DE: 'Delaware',
        DC: 'District of Columbia',
        FM: 'Micronesia1',
        FL: 'Florida',
        GA: 'Georgia',
        GU: 'Guam',
        HI: 'Hawaii',
        ID: 'Idaho',
        IL: 'Illinois',
        IN: 'Indiana',
        IA: 'Iowa',
        KS: 'Kansas',
        KY: 'Kentucky',
        LA: 'Louisiana',
        ME: 'Maine',
        MH: 'Islands1',
        MD: 'Maryland',
        MA: 'Massachusetts',
        MI: 'Michigan',
        MN: 'Minnesota',
        MS: 'Mississippi',
        MO: 'Missouri',
        MT: 'Montana',
        NE: 'Nebraska',
        NV: 'Nevada',
        NH: 'New Hampshire',
        NJ: 'New Jersey',
        NM: 'New Mexico',
        NY: 'New York',
        NC: 'North Carolina',
        ND: 'North Dakota',
        OH: 'Ohio',
        OK: 'Oklahoma',
        OR: 'Oregon',
        PW: 'Palau',
        PA: 'Pennsylvania',
        PR: 'Puerto Rico',
        RI: 'Rhode Island',
        SC: 'South Carolina',
        SD: 'South Dakota',
        TN: 'Tennessee',
        TX: 'Texas',
        UT: 'Utah',
        VT: 'Vermont',
        VI: 'Virgin Island',
        VA: 'Virginia',
        WA: 'Washington',
        WV: 'West Virginia',
        WI: 'Wisconsin',
        WY: 'Wyoming'
      }
    end

  end
end
