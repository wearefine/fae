module Admin
  class PrivacyPagesController < Fae::SingletonPagesController
    include Fae::InertiaRenderable

    def edit
      build_assets

      render_fae_form(
        @item,
        fields: self.class.fae_form_fields,
        title: "Edit #{@klass_humanized}",
        index_path: @index_path,
        submit_path: @submit_path,
        submit_method: 'patch',
        delete_path: nil,
        subnav: [['Page Metadata', 'page_metadata']]
      )
    end

    def update
      if @item.update(item_params)
        redirect_to @index_path, notice: t('fae.save_notice')
      else
        build_assets
        redirect_to @index_path,
                    inertia: { errors: fae_inertia_errors(@item) },
                    flash: { alert: t('fae.save_error') }
      end
    end

    def self.fae_form_fields
      [
        { name: :title, type: :text },
        { name: :headline, type: :text },
        { name: :body, type: :textarea, markdown: true },
        { name: :body_2, type: :textarea },
        { name: :seo_title, type: :text, section_id: 'page_metadata', section_title: 'Page Metadata' },
        { name: :seo_description, type: :textarea },
        { name: :social_media_title, type: :text },
        { name: :social_media_description, type: :textarea },
        { name: :social_media_image, type: :image }
      ]
    end

    private

    def build_assets
      @item.build_social_media_image if @item.social_media_image.blank?
    end
  end
end
