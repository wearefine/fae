# Quickstart Guide

This installation guide is for a Rails 5.0 application. We are currently working on support for Rails 5.1.

If you are starting from scratch, install Rails via:

```bash
gem install rails -v '~> 5.0.0'
```

## Installation

1) Add the gem to your `Gemfile` and run `bundle install`.

```ruby
gem 'fae-rails'
```

2) Run Fae's installer.

```bash
rails g fae:install
```

3) Start your Rails server and visit http://localhost:3000/admin to setup your super admin user.

That's it, you are up and running with Fae!

# An Example CMS

To give you an idea of where to go from there, here is a brief walkthrough of an example CMS setup. This example CMS will manage articles, the article categories they belong to and content on an about page.

## Fae's Scaffold Generator

To add an object to manage in Fae, you can use Fae's built in generators to create all necessary files. They are built on the Rails generators and work very similarly.

**First let's scaffold our `ArticleCategory` object:**

```bash
rails g fae:scaffold ArticleCategory name:string position:integer
```

**Next is our `Article` object:**

```bash
rails g fae:scaffold Article title:string slug:string introduction:text body:text date:date hero_image:image pdf:file article_category:references
```

This one has a couple special Fae moves in it. `image` and `file` are custom attribute types that setup everything Fae needs to manage those assets.

_[Learn more about managing images and files](https://www.faecms.com/documentation/tutorials-image_and_files)_

## Fae's Page Generator

Fae has a built-in pages module that let's you define content blocks on a page as attributes on a model. This allows you to get content for an about page via `AboutUsPage.instance` instead of dealing with hard-coded IDs.

To use this module, you'll have to follow Fae's convention, but we have a custom genereator to get you started.

**To generate content blocks for an `AboutUsPage`:**

```bash
rails g fae:page AboutUs hero_image:image headline:string body:text
```

_[Learn more about content blocks and pages](https://www.faecms.com/documentation/topics-pages)_

**Finally, let's add the scaffolded objects to the database:**

```bash
rails db:migrate
```

_Use `rake db:migrate` with Rails 4_

## Customizing the Forms

With those four commands we are now able to manage those three objects in our CMS. There are some things we can do now to make these forms easier to work with.

### Article Categories

Go to http://localhost:3000/admin/article_categories and add/update a couple categories. You'll notice that Fae picked up the `position` attribute and automatically made the categories sortable in the index view.

### Articles

Now let's go to create a new article at http://localhost:3000/admin/articles/new. This form already does the job, but let's make it better. Fae's generators create files in your application so you can customize this form as you please.

Open `app/views/admin/articles/_form.html.slim` and focus on the `main.content` section where the form fields are:

```ruby
main.content
  = fae_input f, :title
  = fae_input f, :slug
  = fae_input f, :introduction
  = fae_input f, :body
  = fae_input f, :date

  = fae_association f, :article_category

  = fae_image_form f, :hero_image
  = fae_file_form f, :pdf
```

**Automatically generate the `slug` from content in the `title`.**

Fae's form helpers offer many options to help you customize. Let's add a class to the `title` field to trigger Fae's slugger feature:

```ruby
= fae_input f, :title, input_class: 'slugger'
```

_[Learn more about Fae's slugger](https://www.faecms.com/documentation/features-slugger)_

**Add a markdown editor to `body`.**

```ruby
= fae_input f, :body, markdown: true
```

**Add a datepicker to `date`.**

Fae also has a number of other form helpers that provide a variety of UI elements.

```ruby
fae_datepicker f, :date
```

_[See documentation on all form helpers](https://www.faecms.com/documentation/helpers-form_helpers)_

## Form Validations

Fae's forms will honor any standard validation rules defined in the model. Fae even has some [helpers for common validation scenerios](https://www.faecms.com/documentation/topics-models#validation).

To add form validations to our articles, we just need to define them in `app/models/article.rb`:

```ruby
validates :title, presence: true
validates :slug, Fae.validation_helpers.slug
```

Fae uses [Judge](https://github.com/joecorcoran/judge) for client side validations. Judge requires you to expose any attributes that have a uniqueness validation. You can do this in `config/initializers/jugde.rb`:

```ruby
Judge.configure do
  expose Article, :slug
end
```

## Navigation

We should update our navigation so these three sections are easy to find. We'll update our `app/models/concerns/fae/navigation_concern.rb` like so:

```ruby
def structure
  [
    item('News', subitems: [
      item('Articles', path: admin_articles_path),
      item('Article Categories', path: admin_article_categories_path),
    ]),
    item('Pages', subitems: [
      item('About Us', path: fae.edit_content_block_path('about_us'))
    ])
  ]
end
```

_[Learn more about setting up your navigation](https://www.faecms.com/documentation/topics-navigation_setup)_

## Scale and Customize

Now that we are up and running with our CMS we can continue to scale it. When you run into a use case that Fae's can't handle, don't fret, Fae is built to be overridden.

Use Rails helpers in place of Fae form helpers, override views, methods and whole classes. Fae even provides concerns to inject custom logic into its base classes.

We want Fae to get you off the ground quickly but be able to scale with your project and all the customized use cases you don't know you need yet.
