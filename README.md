# Meet Fae

[![Build Status](https://travis-ci.org/wearefine/fae.svg?branch=master)](https://travis-ci.org/wearefine/fae)
[![Code Climate](https://codeclimate.com/github/wearefine/fae/badges/gpa.svg)](https://codeclimate.com/github/wearefine/fae)
![Shippable Status](https://img.shields.io/shippable/5522ec125ab6cc1352b9bb77.svg)

Fae is CMS for Rails unlike any other. Like most Rails CMS engines, Fae provides all the basics to get you up and running: authentication, a responsive UI, form element and workflows. But unlike other CMS engines, Fae's methodology is based around generators and a DSL over configuration. This allows you to get to a working CMS very quickly, but gives you the flexibility to customize any piece you need.

## Installation

Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae-rails'
```
Run the installer

```bash
$ rails g fae:install
```

After the installer completes, visit `/admin` and setup your first user account. That should automatically log you in to your blank Fae instance.

### Dependencies

#### Rails

Fae supports Rails >= 4.1.

#### Sass and sass-rails

Fae requires `sass >= 3.4` and `sass-rails >= 5`.

If you're using Rails 4.1 you'll need to update the versions in the `Gemfile`:

```ruby
gem 'sass-rails', '~> 5.0.0'
gem 'sass', '~> 3.4.0'
```

and run:

```bash
$ bundle update sass-rails
$ bundle update sass
```

## Documentation

### Topics

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


### Features

* [Global Search](docs/features/search.md)
* [Filtering, Pagination and Sorting](docs/features/filtering.md)
* [Authorization](docs/features/authorization.md)
* [Multi-Language Support](docs/features/multi_language.md)
* [Cloning](docs/features/cloning.md)
* [Change Tracker](docs/features/change_tracker.md)
* [Slugger](docs/features/slugger.md)
* [Disabling Environments](docs/features/disable_envs.md)


### Tutorials

* [Adding Conditional Validations](docs/tutorials/conditional_validations.md)
* [Custom Image Processing](docs/tutorials/custom_images.md)
* [Overriding The Landing Page](docs/tutorials/landing_page.md)
* [Devise Action Mailer Configuration](docs/tutorials/actionmailer.md)


### Helper/DSL Docs

* [Fae Styles](docs/helpers/styles.md)
* [Form Helpers](docs/helpers/form_helpers.md)
* [Nested Form Helpers](docs/helpers/nested_form_helpers.md)
* [View Helpers](docs/helpers/view_helpers.md)
* [Fae Partials](docs/helpers/partials.md)

### Contributing

* [Running Fae Locally](docs/contributing/local_setup.md)
* [Fae Standards](docs/contributing/standards.md)

## [Upgrading](docs/upgrading/index.md)

## [Changelog](CHANGELOG.md)

## [MIT License](LICENSE)

