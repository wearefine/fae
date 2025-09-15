FactoryBot.define do

  factory :fae_image, class: 'Fae::Image' do
    # https://github.com/docker/for-mac/issues/5570
    file = File.open(File.join('spec', 'support', 'assets', 'test.jpg'))
    asset { Rack::Test::UploadedFile.new(file, 'image/jpeg', true, original_filename: 'test.jpg') }
  end

  factory :fae_image_svg, class: 'Fae::Image' do
    file = File.open(File.join('spec', 'support', 'assets', 'test.svg'))
    asset { Rack::Test::UploadedFile.new(file, 'image/svg+xml', true, original_filename: 'test.svg') }
  end

end