module Admin
  class IntroPagesController < Fae::SingletonPagesController
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
        delete_path: nil
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
        { name: :body, type: :textarea },
        { name: :date, type: :datepicker },
        { name: :image, type: :image },
        { name: :pdf, type: :file },
        { name: :article_id, type: :select, collection: Article.for_fae_index }
      ]
    end


    private



    def build_assets
      @item.build_image if @item.image.blank?
      @item.build_pdf if @item.pdf.blank?
    end

  end
end
