# Contributing and Maintenance

## Dummy App

There is a dummy app included in the Engine source. To get it running, follow these steps.

Cd to the dummy app:

```
$ cd spec/dummy
```

Create the DB if you haven't already and migrate:

```
$ rake db:create:all
$ rake db:migrate
$ rake db:test:prepare
```

Seed the DB if you haven't already:

```
$ rake fae:seed_db
```

Fire up the server:

```
$ rails s
```

## Testing

The dummy app should stay up-to-date with the latest Rails version we support. Running tests against it will run all specs against that version.

Use [guard](https://github.com/guard/guard-rspec) to have specs autorunning as you change files

```
$ guard
```

### Appraisal

[Appraisal](https://github.com/thoughtbot/appraisal) is an amazing gem that allows us to run the specs against multiple versions of Rails. You can find all support versions in the `Appraisals` file.

To run all appraisals:

```
$ appraisal rspec
```

Or you can run a specific version using the name defined in `Appraisals`:

```
$ appraisal rails_4_2 rspec
```

