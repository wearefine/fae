# Language Translation

Fae supports translating text fields from English to any lanuage supported by Microsoft Translator. Clicking translate button with take the corisponding english field and and output the translated text in the appropriate field.

* [Configure](#configure)
* [Internalization of Pages and Content Blocks](#internalization-of-pages-and-content-blocks)

---

## Configure

To set up the language translation first follow the set up for Multiple Language Support, as this feature depends on that set up.

[Multi-Language Support](docs/features/multi_language.md)

After that is complete, add the following two ENV vars.

```ruby
TRANSLATOR_TEXT_SUBSCRIPTION_KEY
TRANSLATOR_TEXT_REGION
```

Both values can be found in your Microsoft Translator account.

Once all this is done, go to `/admin/root` and check the Enable Language Translations field and save. This should enable the translation feature (translateable fields will have a 'Translate' button that will call MS Translor and return the value in the non-english field).

## Internalization of Pages and Content Blocks

If there is a translatable field that you do not acutally want to be translated (URLs, slugs, ect...) simply add 'translation: false' to the field view. This will remove the 'Translate' button from that field only.

```ruby
= fae_input f, :name_zh, translate: false
```