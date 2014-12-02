class <%= options.namespace.capitalize %>::ContentBlocksController < Fae::StaticPagesController

  private

  def fae_pages
    [<%= "#{class_name}Page" %>]
  end
end
