# Running Fae Locally

## Dependencies

Before you fire this up locally, you'll need some dependencies installed.

- Ruby 2.3.1 via your version manager of choice
- MySQL
- ImageMagick
    + the easiest way to install ImageMagick is with Homebrew
    `brew install imagemagick`
- [QT for capybara-webkit](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#os-x-el-capitan-1011-and-yosemite-1010)

## Dummy App

There is a dummy app included in the Engine source. To get it running, follow these steps.

After cloning the repo, cd into Fae and install gems into a gemset on Ruby 2.3.1:

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

## Testing

The dummy app should stay up-to-date with the latest Rails version we support. Running tests against it will run all specs against that version.

Use [guard](https://github.com/guard/guard-rspec) to have specs autorunning as you change files

```bash
guard
```

### Appraisal

[Appraisal](https://github.com/thoughtbot/appraisal) is an amazing gem that allows us to run the specs against multiple versions of Rails. You can find all support versions in the `Appraisals` file.

To run all appraisals, first install all of the gems of the different appraisal versions with:

```bash
appraisal
```

To run tests in all appraisal versions:

```bash
appraisal rspec
```

Or you can run a specific version using the name defined in `Appraisals`:

```bash
appraisal rails_4_2 rspec
```

