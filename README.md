# Fae


### CMS for Rails. For Reals.

[![Code Climate](https://codeclimate.com/github/wearefine/fae/badges/gpa.svg)](https://codeclimate.com/github/wearefine/fae)

Like many Rails CMS engines, Fae delivers all the basics to get you up and running quickly: authentication, authorization, a sleek UI, form helpers, image processing and workflows. But unlike other engines, Fae's generated models, controllers, and views are built to customize and scale.

Fae 3.x supports Rails 7. For legacy Rails support you can use Fae 2.x on Rails 5.0 to 5.2.

## Installation

1) Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae-rails'
```

2) Run the installer

```bash
$ rails g fae:install
```

3) Visit `/admin` and setup your super admin account

## Documentation

For full documentation visit:
https://www.faecms.com/documentation

### Topics

* [Quickstart Guide](docs/quickstart-guide.md)
* [Installation](docs/installation/index.md)
* [Generators](docs/topics/generators.md)
* [Navigation Setup](docs/topics/navigation_setup.md)
* [Initializer](docs/topics/initializer.md)
* [Models](docs/topics/models.md)
* [Controllers](docs/topics/controllers_and_concerns.md)
* [Fae Model and Controller Concerns](docs/topics/concerns.md)
* [Override Uploaders and Classes](docs/topics/override_uploaders_and_classes.md)
* [Pages and Content Blocks](docs/topics/pages.md)
* [Custom JS, CSS and Helpers](docs/topics/custom_js_css.md)
* [Root Settings](docs/topics/root_settings.md)
* [Caching](docs/topics/caching.md)


### Features

* [Global Search](docs/features/search.md)
* [Filtering, Pagination and Sorting](docs/features/filtering.md)
* [Authorization](docs/features/authorization.md)
* [Multi-Language Support](docs/features/multi_language.md)
* [Language Translation](docs/features/language_translate.md)
* [Cloning](docs/features/cloning.md)
* [Change Tracker](docs/features/change_tracker.md)
* [Slugger](docs/features/slugger.md)
* [Disabling Environments](docs/features/disable_envs.md)
* [Form Field Label & Helper Text Manager](docs/features/form_manager.md)
* [Netlify Deploy Monitor](docs/features/netlify.md)
* [Multi-Factor Authentication via OTP](docs/features/mutli_factor_authentication.md)
* [Slack Notifications](docs/features/slack_notifications.md)


### Tutorials

* [Setting Up SEO with Fae](docs/tutorials/seo.md)
* [Setting Up GraphQL with Fae](docs/tutorials/graphql_support.md)
* [Setting Up Images and Files](docs/tutorials/image_and_files.md)
* [Adding Dynamic Relationships to Pages](docs/tutorials/dynamic_relationships_to_pages.md)
* [Adding Conditional Validations](docs/tutorials/conditional_validations.md)
* [Custom Image Processing](docs/tutorials/custom_images.md)
* [Overriding The Landing Page](docs/tutorials/landing_page.md)
* [Overriding The Markdown Helper](docs/tutorials/markdown_helper.md)
* [Devise Action Mailer Configuration](docs/tutorials/actionmailer.md)
* [Setting Up Parent/Child Objects](docs/tutorials/parent_child_objects.md)
* [Configuring With Existing Devise Setup](docs/tutorials/existing_devise.md)


### Helper/DSL Docs

* [Fae Styles](docs/helpers/styles.md)
* [Form Helpers](docs/helpers/form_helpers.md)
* [Nested Form Helpers](docs/helpers/nested_form_helpers.md)
* [View Helpers](docs/helpers/view_helpers.md)
* [Fae Partials](docs/helpers/partials.md)

### Contributing

* [Running Fae Locally](docs/contributing/local_setup.md)
* [Fae Standards](docs/contributing/standards.md)
* [Share Your Creation](docs/contributing/share_your_creation.md)

## [Upgrading](docs/upgrading/index.md)

## [Changelog](CHANGELOG.md)

## [MIT License](LICENSE)

