module Fae
  module FlexComponentConcern
    extend ActiveSupport::Concern

    included do    
      def fae_display_field
        component_instance.fae_display_field
      end
    
      def preview_image_url
    
      end
    end
  
    class_methods do
      def base_components
        []
      end
  
      # Including this as an example of how to conditionally include components based on the model
      def page_components
        []
      end
  
      # Used in the flex component form to populate the component dropdown
      def components_for(model)
        ret = base_components
        ret += page_components if model == 'Fae::StaticPage'
        ret.sort.collect{ |c| [c.titleize.gsub('Component',''), c] }
      end
    end

  end
end