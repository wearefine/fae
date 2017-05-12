module <%= options.namespace.capitalize %>
  class ContentBlocksController < Fae::StaticPagesController

    private

    def fae_pages
      [<%= "#{class_name}Page" %>]
    end
  end
end
