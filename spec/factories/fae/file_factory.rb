FactoryBot.define do

  factory :fae_file, class: 'Fae::File' do
    asset { Rack::Test::UploadedFile.new(File.join('spec', 'support', 'assets', 'test.pdf')) }
  end

end