module <%= options.namespace.capitalize %>
  class ContentBlocksController < Fae::StaticPagesController

    private

    def fae_pages
      [<%= "#{class_name.singularize}Page" %>]
    end
  end
end
