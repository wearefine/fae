# Running Fae Locally

## Dependencies

Before you fire this up locally, you'll need some dependencies installed.

- Ruby 3.3 via your version manager of choice
- MySQL
- ImageMagick
    + the easiest way to install ImageMagick is with Homebrew
    `brew install imagemagick`
- Google Chrome or Chromium, used headlessly by [Cuprite](https://github.com/rubycdp/cuprite) for JS feature specs

## Dummy App

There is a dummy app included in the Engine source. To get it running, follow these steps.

After cloning the repo, cd into Fae and install gems on Ruby 3.3:

```bash
cd path/to/fae
bundle install
```

Cd to the dummy app:

```bash
cd spec/dummy
```

Create the DB and migrate:

```bash
rake db:create
rake db:migrate && rake db:migrate RAILS_ENV=test
```

Seed the DB:

```bash
rake fae:seed_db
```

Fire up the server:

```bash
rails server
```

## Stylesheets

Fae's SCSS lives in `app/stylesheets` and is compiled by [sass-embedded](https://github.com/sass-contrib/sass-embedded-host-ruby) into the prebuilt, committed `app/assets/builds/fae_admin.css`. After changing any SCSS, rebuild it and commit the result:

```bash
bundle exec rake fae:css:build
```

`rake fae:css:watch` rebuilds on every change while you work. A spec fails if the committed CSS is out of date.

## Testing

The dummy app should stay up-to-date with the latest Rails version we support. Running tests against it will run all specs against that version.

Use [guard](https://github.com/guard/guard-rspec) to have specs autorunning as you change files

```bash
guard
```
