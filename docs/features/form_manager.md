# Form Field Label & Helper Text Manager

* [Enabling The Manager](#enabling)
* [Max Characters](#max-characters)
* [Upgrading](#upgrading)

---

## Enabling The Manager

`config/initializers/fae.rb`
```ruby
Fae.setup do |config|

  config.use_form_manager = true

end
```
A "Manage Form" button will now be available for use at the top of your forms that opens the manager overlay.

An additional option is available if you want to disallow a field from being editable:

```slim
= fae_input f, :name, input_class: 'slugger', show_form_manager: false
```

## Max Characters

Text inputs and text areas that have a length validation with a `maximum` also get a "Max Characters" setting in the manager. This includes Fae page content blocks with a `length` validation.

```ruby
validates :name, length: { maximum: 100 }
```

The model's `maximum` is the default. A value saved in the manager replaces it, so it can be raised or lowered without changing the model. The setting's placeholder shows the current value and the largest value allowed (e.g. "Set to 100, Max 255"). Leaving it blank keeps the current value; enter the model's default to remove the override. Other length options, such as `minimum`, still apply.

The override is used everywhere the model's maximum is used:

* the server-side validation when the record is saved
* the client-side validation and the "Maximum Characters / Characters Left" counter

The largest value the manager accepts depends on the database column and the field type:

* If the database reports a column limit (e.g. `t.string :name, limit: 255`), that limit is the ceiling.
* If it doesn't, text inputs allow up to 255 and text areas allow up to 65,535. A model default above these limits raises the ceiling to match.

On the server, overrides are only capped by a column limit that the database reports.

Only `maximum` values set to a fixed integer can be overridden; validations that use a Proc or Symbol are left as-is.

## Upgrading
After updating the FAE gem and bundling
1. `rake fae:install:migrations`
2. `rake db:migrate`
3. Due to the generated nature of FAE's forms, you're going to have to edit any `form.html.slim` files that have already been generated where you want to use the manager.

### Main Forms

Replace

```slim
<%= simple_form_for([:admin, @item]) do |f| %>
```

With

```slim
ruby:
  form_options = {
    html: {
      data: {
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for([:admin, @item], form_options) do |f|
```

### Pages / Content Blocks

Replace

```slim
= simple_form_for @item, url: fae.update_content_block_path(slug: @item.slug), method: :put do |f|
```

With

```slim
ruby:
  form_options = {
    url: fae.update_content_block_path(slug: @item.slug),
    method: :put,
    html: {
      data: {
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_model_id: @item.fae_form_manager_model_id,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for @item, form_options do |f|
```

### Nested Forms

Replace

```slim
= simple_form_for([:admin, @item], html: {multipart: true, novalidate: true, class: 'js-file-form'}, remote: true, data: {type: "html"}) do |f|
```

With

```slim
ruby:
  form_options = {
    html: {
      multipart: true,
      novalidate: true,
      class: 'js-file-form',
      remote: true,
      data: {
        type: "html",
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for([:admin, @item], form_options) do |f|
```

Then at the bottom of the form, after
```slim
= f.button :submit, t('fae.form.save'), data: { disable_with: t('fae.form.saving') }
= button_tag 'Cancel', type: 'button', class: 'js-cancel-nested cancel-nested-button'
```
Add
```slim
- if Fae.use_form_manager
  a.button.js-launch-form-manager href='#' = t('fae.form.launch_form_manager')
```
So the new form will look like
```slim
ruby:
  form_options = {
    html: {
      multipart: true,
      novalidate: true,
      class: 'js-file-form',
      remote: true,
      data: {
        type: "html",
        form_manager_model: @item.fae_form_manager_model_name,
        form_manager_info: (@form_manager.present? ? @form_manager.to_json : nil)
      }
    }
  }
= simple_form_for([:admin, @item], form_options) do |f|
  = fae_input f, :name, input_class: 'slugger'
  = fae_input f, :slug, helper_text: 'default'

  = f.button :submit, t('fae.form.save'), data: { disable_with: t('fae.form.saving') }
  = button_tag 'Cancel', type: 'button', class: 'js-cancel-nested cancel-nested-button'
  - if Fae.use_form_manager
    a.button.js-launch-form-manager href='#' = t('fae.form.launch_form_manager')
```
