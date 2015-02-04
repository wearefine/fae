# Meet Fae

## Installation

Add the gem to your Gemfile and run `bundle install`

```ruby
gem 'fae', git: 'git@bitbucket.org:wearefine/fae.git'
```
Run the installer

```bash
$ rails g fae:install
```

Restart your server

## Dependencies

### Rails

Fae currently supports Rails 4.1.x. 4.2 support is in the works.

### Sass and sass-rails

Fae also requires the following versions:

```ruby
gem 'sass-rails', '~> 5.0.0'
gem 'sass', '~> 3.4.0'
```

These aren't within the default range of rails 4.1, so you'll need to update the versions in the `Gemfile` and run:

```bash
$ bundle update sass-rails
$ bundle update sass
```

## Documentation

- [Main documentation and usage](/wearefine/fae/src/master/docs/index.md)
- [Form and view helpers](/wearefine/fae/src/master/docs/helpers.md)

## Contributing/Maintenance

Maintenance specific information can be found in [CONTRIBUTING.md](/wearefine/fae/src/master/CONTRIBUTING.md)





