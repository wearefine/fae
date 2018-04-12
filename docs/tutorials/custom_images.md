# Custom Image Processing

There are times when you need to have different sizes of images, and you can override the `image_upload.rb` file to achieve this goal

By default, Fae includes a thumbnail size called `thumb` that is triggered like so:

```ruby
= image_tag(item.image.asset.thumb.url)
```

You may copy the contents of the `uploaders/fae/image_upload.rb` file and add your own options, such as mobile and tablet and call them the same way.

```ruby
# encoding: utf-8
module Fae
  class ImageUploader < CarrierWave::Uploader::Base
    include CarrierWave::RMagick

    # saves file size to DB
    process :save_file_size_in_model
    def save_file_size_in_model
      model.file_size = file.size
    end

    def extension_white_list
      %w(jpg jpeg gif png ico)
    end

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      "system/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    version :mobile do
      process :resize_to_fill => [320,510]
    end

    version :tablet do
      process :resize_to_fill => [768,960]
    end

    version :thumb do
      process :resize_to_fill => [150,100]
    end
  end
end
```

View:

```ruby
= image_tag(item.image.asset.tablet.url)
```