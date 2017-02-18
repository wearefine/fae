# Generators

Once you have Fae installed, you're ready to start generating your data model. Fae comes with a few generators that work similarly to the ones in Rails. The idea is scaffolding a model with these generators will give you a section to create, edit and delete objects.

* [Fae Scaffold](#fae-scaffold)
* [Fae Nested Scaffold](#fae-nested-scaffold)
* [Fae Page](#fae-page)

---

## Fae Scaffold

```bash
rails g fae:scaffold [ModelName] [field:type] [field:type]
```
| option | description |
|------- | ----------- |
| ModelName | singular camel-cased model name |
| field | the attributes column name |
| type | the column type (defaults to `string`), find all options in [Rails' documentaion](http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#method-i-column) |

This is Fae's main generator. It will create the following:

- model
- controller and views for fully CRUDable section
- migration
- resource routes
- link in `app/controllers/concerns/fae/nav_items.rb`

### Special Attributes

**name**/**title** will automatically be set as the model's `fae_display_field`.

**position** will automatically make the section's index table sortable, be ignored from the form and add acts_as_list and default_scope to the model.

**on_prod**/**on_stage**/**active** will automatically be flag fields in the section's index and ignored in the form.

**_id**/**:references** will automatically be setup as an association in the form.

**:image or :file** will automatically create image/file attachment associations in the model, asset builders in the controller, and file uploaders in the form.

### Example

```bash
rails g fae:scaffold Person first_name last_name title body:text date_of_birth:date position:integer on_stage:boolean on_prod:boolean head_shot:image bio_pdf:file group:references
```


## Fae Nested Scaffold

```bash
rails g fae:nested_scaffold [ModelName] [field:type] [field:type] [--parent-model=ParentModel]
```

| option | description |
| ------ | ----------- |
| `[--parent-model=ParentModel]` | an optional flag that adds the association to the generated model.|

The nested scaffold creates a model that is meant to be nested in another object's form via the `nested_table` partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to serve the nested form.

* [More information on nested forms](#nested-forms)
* [More information on the nested_table partial](helpers.md#nested_table)

## fae:nested_index_scaffold

```bash
rails g fae:nested_index_scaffold [ModelName] [field:type] [field:type]
```

The nested index scaffold creates a normal model and a controller that supports the nested_index_form partial. This generator is very similar to `fae:scaffold`, the main difference is in the views that are setup to serve the nested form.

## Fae Page

```bash
rails g fae:page [PageName] [field:type] [field:type]
```

| option  | description |
|---------|-------------|
| PageName | the name of the page |
| field   | the name of the content block |
| type    | the type of the content block (see [table below](#pages-vs-content-blocks)) |

The page generator scaffolds a page into Fae's content blocks system. More on that later, for now here's what it does:

- creates or adds to `app/controllers/admin/content_blocks_controller.rb`
- creates a `#{page_name}_page.rb` model
- creates a form view in `app/views/admin/content_blocks/#{page_name}.html.slim`

### Example

```bash
rails g fae:page AboutUs title:string introduction:text body:text header_image:image
```