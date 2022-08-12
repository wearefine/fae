CarrierWave.configure do |config|
   config.cache_dir = "#{Rails.root}/tmp/fae/uploads"

   if Rails.env.production? || Rails.env.remote_development?
     config.fog_provider = 'fog/aws'
     config.fog_credentials = {
       provider: 'AWS',
       aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
       aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
       region: 'us-west-2'
     }
     config.storage = :fog
   else
     config.storage = :file
   end

   if Rails.env.production?
      config.asset_host = 'https://s3.us-west-2.amazonaws.com/fae-engine-test-fly'
      config.fog_directory = 'fae-engine-test-fly'
   elsif Rails.env.remote_development?

   end

   # uncomment to deliver production assets to the local CMS
   # if Rails.env.development?
   #   config.asset_host = ''
   #   config.fog_directory = ''
   # end

   # uncomment to upload to bucket/cdn in local dev
   # if Rails.env.development?
   #   config.fog_provider = 'fog/aws'
   #   config.fog_credentials = {
   #     provider: 'AWS',
   #     aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
   #     aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
   #     region: 'us-west-2'
   #   }
   #   config.storage = :fog
   # end

 end
