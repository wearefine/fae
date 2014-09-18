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

### Helper Methods

All FAE helper methods add the ability to use simpler syntax for input class and wrapper class - respectively 'class' and 'wrapper_class'
```
fae_input f, :state, wrapper_class: 'special_wrapper', class: 'special_input'
fae_association f, :child, wrapper_class: 'unique_wrapper', class: 'unique_input'
```

The prefix and suffix helpers both have a required option of *prefix* and *suffix*
`fae_prefix f, :amount, prefix: '$'`
![Alt text](http://www.afinesite.com/fae/fae_prefix.jpg)

The radio helper allows for an option to align it vertically or horizontally, the default is vertical. It also works for associations with a required 'collection' option that takes a multi-dimentional array or ActiveRecord#Relation object as a value.
`fae_radio f, :on_prod, alignment: 'stacked'`
![Alt text](http://www.afinesite.com/fae/fae_radio_stacked.png)

`fae_radio f, :on_prod, alignment: 'inline'`
![Alt text](http://www.afinesite.com/fae/fae_radio_inline.png)

`fae_radio f, :acclaims, collection: Acclaims.all`

The pulldown helper adds a dropdown with a search field on your associations or model attributes. It takes a *size* option that accepts 'short' or 'long', 'long' is the default. This helper by default works on associations and inputs, if you want to use it on inputs you must specify a 'collection' as a multi-dimentional array or an ActiveRecord#Relation object as a value.
`fae_pulldown f, :wine`
![Alt text](http://www.afinesite.com/fae/long_pulldown.png)
`fae_pulldown f, :wine, size: 'short'`
![Alt text](http://www.afinesite.com/fae/short_pulldown.png)
`fae_pulldown f, :price, collection: [['$1.00',1],['$2.00',2]]` or `fae_pulldown f, :price, collection [1,2]`

The multiselect helper takes an optional parameter of 'two_pane' which takes a Boolean. This method is restricted to ActiveRecord#Relation's.
`<%= fae_multiselect f, :acclaims, label_method: :publication %>`
![Alt text](http://www.afinesite.com/fae/multiselect_dropdown.png)
`<%= fae_multiselect f, :selling_points, two_pane: true %>`
![Alt text](http://www.afinesite.com/fae/multiselect_two_pane.png)



