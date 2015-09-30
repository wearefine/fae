class Admin::ContentBlocksController < Fae::StaticPagesController

  private

  def fae_pages
    [HomePage, AboutUsPage]
  end
end
