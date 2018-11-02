# Custom Image Processing

There are times when you need to have different sizes of images, and you can override the `image_upload.rb` file to achieve this goal

By default, Fae includes a thumbnail size called `thumb` that is triggered like so:

```ruby
= image_tag(item.image.asset.thumb.url)
```

If you need to add your own image versions to Carrierwave you may copy the contents of the https://github.com/wearefine/fae/blob/master/app/uploaders/fae/image_uploader.rb to `app/uploaders/fae/image_uploader.rb` of the parent application. From there you can add any custom image proccessing you like.

The caveat being any bugfixes or features added to this file in Fae will now be ignored in favor of your local file. If you are updating Fae, you may want to verify this base file hasn't changed.

In this example we will be adding some extra versions to support a responsive design:

```ruby
version :mobile do
  process :resize_to_fill => [320,510]
end

version :tablet do
  process :resize_to_fill => [768,960]
end
```

Then to access the versions in the view:

```ruby
= image_tag(item.image.asset.tablet.url)
```
