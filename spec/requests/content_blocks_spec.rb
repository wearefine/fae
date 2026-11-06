require 'rails_helper'

describe 'content_blocks#index' do

  it 'should return found' do
    admin_login
    get fae.pages_path

    expect(response.status).to eq(200)
  end

end

describe 'content_blocks#edit' do

  it 'should return found' do
    admin_login
    get fae.edit_content_block_path('home')

    expect(response.status).to eq(200)
  end

  it 'should render saved video records so finished uploads can attach immediately' do
    admin_login
    get fae.edit_content_block_path('about_us')

    expect(response.status).to eq(200)
    page = AboutUsPage.instance
    %w(hero_video intro_video_en intro_video_zh intro_video_frca).each do |name|
      video = page.send(name)
      expect(video).to be_persisted
      expect(video.attached_as).to eq(name)
      expect(response.body).to include(fae.attach_video_upload_path(video.id))
    end
  end

end

describe 'content_blocks#update with videos' do

  before do
    admin_login
    allow_any_instance_of(Fae::Video).to receive(:sync_with_mux)
    get fae.edit_content_block_path('about_us') # builds the page's content block records
  end

  it 'should save uploads to plain and per-language video blocks' do
    page = AboutUsPage.instance

    put fae.update_content_block_path('about_us'), params: {
      about_us_page: {
        title: 'About Us',
        header_attributes: { attached_as: 'header', content: 'Header' }, # presence-validated, so the edit page can't pre-build it
        hero_video_attributes: { id: page.hero_video.id, upload_id: 'uploadHero', attached_as: 'hero_video', videoable_type: 'Fae::StaticPage' },
        intro_video_zh_attributes: { id: page.intro_video_zh.id, upload_id: 'uploadZH', attached_as: 'intro_video_zh', videoable_type: 'Fae::StaticPage' }
      }
    }

    expect(response).to redirect_to(%r{/pages})
    page = AboutUsPage.instance
    expect(page.hero_video.upload_id).to eq('uploadHero')
    expect(page.hero_video.mux_environment).to eq(Fae::Video.mux_environment)
    expect(page.intro_video_zh.upload_id).to eq('uploadZH')
    expect(page.intro_video_en.upload_id).to be_nil
  end

  it 'should render the language suffix in the uploader so saving keeps each language separate' do
    get fae.edit_content_block_path('about_us')

    expect(response.body).to include('value="intro_video_zh"')
    expect(response.body).not_to include('value="intro_video"')
  end

end
