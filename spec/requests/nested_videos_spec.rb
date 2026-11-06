require 'rails_helper'

# Videos in AJAX'd nested forms (nested tables and flex components), e.g. on admin/article_categories
describe 'videos in nested forms and flex components' do

  let(:category) { ArticleCategory.create!(name: 'Category') }

  before do
    admin_login
    allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
  end

  def uploader_wrapper(body, attached_as = 'video')
    Nokogiri::HTML(body).at_css(".input.video.#{attached_as}")
  end

  describe 'nested table item' do

    it 'should render an uploader in the new form' do
      get "/admin/article_subcategories/new", params: { item_id: category.id }

      expect(response.status).to eq(200)
      wrapper = uploader_wrapper(response.body)
      expect(wrapper.at_css('mux-uploader.js-mux-uploader')).to be_present
      expect(wrapper.at_css('input[name="article_subcategory[video_attributes][videoable_type]"]')['value']).to eq('ArticleSubcategory')
      expect(wrapper.at_css('input[name="article_subcategory[video_attributes][attached_as]"]')['value']).to eq('video')
    end

    it 'should save an upload when the nested item is created' do
      post '/admin/article_subcategories', params: {
        article_subcategory: {
          name: 'Sub',
          article_category_id: category.id,
          video_attributes: { upload_id: 'uploadNested', title: 'clip.mp4', attached_as: 'video', videoable_type: 'ArticleSubcategory' }
        }
      }

      expect(response.status).to eq(200)
      video = ArticleSubcategory.find_by(name: 'Sub').video
      expect(video.upload_id).to eq('uploadNested')
      expect(video.title).to eq('clip.mp4')
      expect(video.mux_environment).to eq(Fae::Video.mux_environment)
    end

    it 'should show the saved video when the nested item is edited' do
      sub = category.article_subcategories.create!(name: 'Sub')
      video = sub.create_video!(upload_id: 'uploadNested', attached_as: 'video')

      get "/admin/article_subcategories/#{sub.id}/edit"

      wrapper = uploader_wrapper(response.body)
      expect(wrapper['data-attach-url']).to eq(fae.attach_video_upload_path(video.id))
      expect(wrapper.at_css('.asset-actions.-video')).to be_present
      # fields_for adds the id after the block, outside the wrapper
      expect(Nokogiri::HTML(response.body).at_css('input[name="article_subcategory[video_attributes][id]"]')['value']).to eq(video.id.to_s)
    end

  end

  describe 'flex component' do

    let(:hero) do
      component = HeroComponent.create!(title: 'Hero')
      Fae::FlexComponent.create!(
        flex_componentable: category,
        component_model: 'HeroComponent',
        component_id: component.id
      )
      component
    end

    it 'should render an uploader in the component form' do
      get "/admin/hero_components/#{hero.id}/edit", params: { draft: true }

      expect(response.status).to eq(200)
      wrapper = uploader_wrapper(response.body)
      expect(wrapper.at_css('mux-uploader.js-mux-uploader')).to be_present
      expect(wrapper.at_css('input[name="hero_component[video_attributes][videoable_type]"]')['value']).to eq('HeroComponent')
    end

    it 'should save an upload when the component is updated' do
      put "/admin/hero_components/#{hero.id}", params: {
        hero_component: {
          title: 'Hero',
          video_attributes: { upload_id: 'uploadFlex', title: 'hero.mp4', attached_as: 'video', videoable_type: 'HeroComponent' }
        }
      }

      expect(response.status).to eq(200)
      expect(hero.reload.video.upload_id).to eq('uploadFlex')
      expect(hero.video.mux_environment).to eq(Fae::Video.mux_environment)
    end

  end

end
