FactoryGirl.define do

  factory :fae_image, class: 'Fae::Image' do
    asset { Rack::Test::UploadedFile.new(File.join('spec', 'support', 'assets', 'test.jpg')) }
  end

end