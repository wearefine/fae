# Netlify Deploy / Status Log

* [Enabling Deploys](#enabling)
* [Upgrading](#upgrading)

---

## Enabling Deploys

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
= f.submit
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

  = f.submit
  = button_tag 'Cancel', type: 'button', class: 'js-cancel-nested cancel-nested-button'
  - if Fae.use_form_manager
    a.button.js-launch-form-manager href='#' = t('fae.form.launch_form_manager')
```
