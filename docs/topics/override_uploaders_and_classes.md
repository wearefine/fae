# Override Uploaders and Classes

* [Overriding Classes](#overriding-classes)
* [Overriding Uploaders](#overriding-uploaders)

---

## Overriding Classes

If there's no way to inherit from or inject into a Fae class, your last effort would be to override it. To do that, simply copy the Fae class into your application in the same path found in Fae and customize it from there.

E.g. if you need to customize Fae's `image_controller.rb`, copy the file from Fae into your application at `app/controllers/fae/image_controller.rb`.

## Overriding Uploaders

If you need to override the uploaders `Fae::Image` and `Fae::File` use, you can use the method in the previous section. To customize the `Fae::ImageUploader` just copy file to `app/uploaders/fae/image_uploader.rb` and make your updates.

This is handy when you need to update the `extension_white_list` or set your own resizing logic.

Note: If you just need to increase the file upload limit, see the options in [Initializer](docs/topics/initializer.md), no need to override the whole file.


In `config/initializers/fae.rb`:

```ruby
config.max_image_upload_size = x
config.max_file_upload_size = x
```
