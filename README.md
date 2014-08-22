# Meet Fae

## Installation

* add the gem to your Gemfile

		gem 'fae', :git => 'git@bitbucket.org:wearefine/fae.git’

* configure devise

		$ rails generate devise:install

## Maintainer notes

### Dummy App

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
$ rails console
> Fae::Engine.load_seed
```

Fire up the server:

```
$ rails s
```