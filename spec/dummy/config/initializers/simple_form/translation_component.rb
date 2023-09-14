module SimpleForm
  module Components
    module Translation
      def translation
        if options[:translate].present?
          translate = options[:translate]
          # tooltip_content = tooltip.is_a?(String) ? tooltip : translate(:tooltips)
          # tooltip_content.html_safe if tooltip_content
          template.content_tag(:span, :class => 'button', :label => 'Translate')
        end
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::Translation)