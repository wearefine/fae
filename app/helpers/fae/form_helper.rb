module Fae
  module FormHelper

    def test_method
      link_to('test', '#')
    end

    def fae_input(f, attribute, options={})
      content_tag :div, class: "input #{(options.delete(:wrapper_class) if options[:wrapper_class])}" do
        
        concat label_tag("#{@klass_singular}_#{attribute}", attribute.to_s.titleize, class: ('required' if options[:required]))

        if options[:helper_text]
          concat content_tag :h6, options[:helper_text], class: 'helper_text'
        end

        concat f.input_field attribute, options

        if options[:hint]
          concat content_tag :div, options[:hint].html_safe, class: 'hint'
        end
      end
    end

    def fae_currency(f, attribute, options={})
      content_tag :div, class: "input input-icon-currency" do
        
        concat label_tag("#{@klass_singular}_#{attribute}", attribute.to_s.titleize, class: ('required' if options[:required]))

        if options[:helper_text]
          concat content_tag :h6, options[:helper_text], class: 'helper_text'
        end

        concat f.input_field attribute, options

        if options[:hint]
          concat content_tag :div, options[:hint].html_safe, class: 'hint'
        end
      end
    end

  end
end
