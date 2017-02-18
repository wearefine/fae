# Quickstart Guide

_This Quickstart Guide is written with Rails 5 in mind._

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

You will now be logged in to your blank Fae instance.

## An Example CMS

To give you an idea of where to go from there, here is a brief walkthrough of an example CMS setup.

This example CMS will manage articles, the article categories they belong to and content on an about page.

### Run Fae's Generators

```bash
rails g fae:scaffold ArticleCategory name position:integer
rails g fae:scaffold Article title slug introduction:text body:text date:date hero_image:image pdf:file article_category:references
rails g fae:page AboutUs hero_image:image headline:string body:text
rails db:migrate
```

### Add validations

### Customize the Forms

- move category to top
- add slugger
- add markdown to intro
- add datepicker

### Customize Nav
