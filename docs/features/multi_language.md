# Multiple Language Support

Fae support a language nav that makes managing content in multiple languages easy. The language nav will display all available languages. Clicking a specific language will only display fields specific to that language.

* [Configure](#configure)
* [Database Column Naming](#database-column-naming)
* [Displaying the Language Nav](#displaying-the-language-nav)

---

## Configure

To setup the language nav first define all languages Fae will be managing content in.

`config/initializers/fae.rb`
```ruby
config.languages = {
  en: 'English',
  zh: 'Chinese',
  ja: 'Japanese'
}
```

The convention of this hash is important as the keys with have to match the database column suffixes of the specific language fields. The values will be used as the link text in the language nav.

## Database Column Naming

As mentioned above, the column names of fields supporting multiple languages will have to follow this convention:

```
"#{attribute_name}_#{language_abbreviation}`
```

E.g. the english version of the title attribute would be `title_en`.

Using Fae's generators let's quickly scaffold a model that supports multiple languages (columns without suffixes will be treated normally:

```bash
$ rails g fae:scaffold Person name title_en title_zh title_ja intro_en:text intro_zh:text intro_ja:text
```

To retrieve the correct attribute on the front-end, list translated attributes **without** their language abbreviation in the `fae_translate` class method.

```ruby
class Person < ActiveRecord::Base
  include Fae::Concerns::Models::Base

  fae_translate :name, :title, :intro
end

# i.e. if English is the locale, @person.name == @person.name_en
```

International records can also be retrieved using `find_by_#{attribute}`:

```ruby
class PeopleController < ApplicationController
  def index
    @person = Person.find_by_name(params[:name])
  end
end
```

## Displaying the Language Nav

Finally, to display the language select menu, you'll need to add `language: true` to your `form_header` partial:

`app/views/admin/people/_form.html.slim`
```slim
= simple_form_for(['admin', @item]) do |f|
  = render 'fae/shared/form_header', header: @klass_name, language: true

  // ...
```

## Internalization of Pages and Content Blocks

Multiple inputs will be generated for blocks that support for multiple languages. Add a `:languages` key to the field's definition.

```ruby
class AboutPage < Fae::StaticPage

  @slug = 'about'

  fae_translate :body, :annual_report

  def self.fae_fields
    {
      body: {
        type: Fae::TextArea,
        languages: [:en, :zh]
      },
      annual_report: {
        type: Fae::File,
        languages: Fae.languages.keys # Set in config/initializers/fae.rb
      }
    }
  end

end
```

Utilizing `fae_translate` in a `Fae::StaticPage` will automatically use the set locale to determine which content to return.

```ruby
# set locale
I18n.locale = :zh

# calling an attribute will return the translation content
AboutPage.instance.body_content
# => content set in body_zh
```

Add `languages: true` to the page's `fae/shared/form_header` partial to utilize Fae's language switcher.

## In the Application

To display the right translation, Rails needs to interpret the requested locale. This can be done with a simple ApplicationController method:

```ruby
# app/controllers/application_controller
class ApplicationController < ActionController::Base
  before_action :set_locale

  private
    def set_locale
      I18n.locale = params[:locale] || request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.presence || I18n.default_locale
    end
end
```

The above assumes that your routes support a `locale` parameter:

```ruby
# config/routes.rb
scope '(:locale)', locale: /en|zh/ do
  get '/' => 'pages#home', as: 'home' # / or /zh
  get '/about' => 'pages#about', as: 'about' # /about or /zh/about
end
```

For URL schemes that require a language locale to always be present, a separate method can be added beneath `private` in the ApplicationController:

```ruby
# Forces locale to appear in the URL, even if the request locale matches the default locale
def default_url_options(options={})
  {locale: I18n.locale }
end
```

The attribute can then be retrieved normally (i.e. `@item.name` will render `@item.name_en` if `I18n.locale` is `:en`).
