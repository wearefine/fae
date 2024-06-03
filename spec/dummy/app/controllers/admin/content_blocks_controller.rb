class Admin::ContentBlocksController < Fae::StaticPagesController

  private

  def fae_pages
    [HomePage, AboutUsPage, ContactUsPage, GlobalContentPage, PrivacyPage, ComponentPagePage]
  end

  def use_pagination
    true
  end
end
