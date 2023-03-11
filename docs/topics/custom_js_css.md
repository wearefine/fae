# Custom JS, CSS and Helpers

* [Fae JS](#fae-js)
* [Fae SCSS](#fae-scss)
* [Custom Helpers](#custom-helpers)

---

Fae creates two files in your assets pipeline that allow custom JS and CSS in your admin.

## Fae JS

`app/assets/javascripts/fae.js` compiles into `fae/application.js`. As noted in the file, you can use it as a mainfest (to add a lot of JS) or to simply add JS directly to.

#### Example: fae.js as a Manifest File

```JavaScript
// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file
//
//= require admin/plugins
//= require admin/main
```

## Fae SCSS

`app/assets/stylesheets/fae.scss` compiles into `fae/application.css`. Styles added to this files will be declared before other Fae styles.

## Custom Helpers

If you want to add your own helper methods for your Fae views, simply create and add them to `app/helpers/fae/fae_helper.rb`.

```ruby
module Fae
  module FaeHelper
    # ...
  end
end
```
