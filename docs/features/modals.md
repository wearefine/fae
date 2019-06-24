# Modals

Many users find it easier to clone records that have similar content, rather than spending the time manually setting them up. Fae has the ability to allow one-click clones from the index or the edit form, as well as flexibility to whitelist attributes and clone assocations.


* [Basic](#basic)
* [Advanced](#advanced)
* [Cloning Associations](#cloning-associations)
* [Fae Clone Button](#fae-clone-button)

---


## Basics

The most basic implementation of this feature clones the record, all it's attributes (except id, created and updated at) and any belongs_to associations via foreign_keys. We also check for any uniqueness validators on your attributes and rename them to "attribute-#", starting at 2, for your convenience.

## Add Modal Trigger

You can add a modal trigger by adding the modal trigger class to any link.

**Examples**

#### For Index

Add the following to your `thead`, usually after 'Delete':

```slim
  <a href="/admin/cats/new" id="cats" class="js-fae-modal">add new cat via modal popup</a>
```

#### For Form

Simply pass `cloneable: true` into your form_header partial. You may also edit the default text 'Clone', by passing in `clone_button_text` and your own string.

```ruby
  render 'fae/shared/form_header', cloneable: true, clone_button_text: 'Duplicate Me!'
```

That's all for basic set-up.

## Advanced

If you want complete control over which attributes and associations are cloned, we wouldn't call you a control freak. We've baked in some nice simple methods to make this possible.

**Note:** Asset cloning is not currently supported, so if you try to pass in those associations, cloning will fail.

## Whitelisting Attributes

If you want to whitelist attributes to be cloned, you may add the `attributes_for_cloning` method into your controller's private method. Just pass in an array of symbols and we will take care to only copy those attributes over.

**Note:** please make sure to include _everything_ that is required, or the record will fail to get created. You've been warned.

**Example**

```ruby
def attributes_for_cloning
  [:name, :slug, :description, :wine_id]
end
```

## Cloning Associations

Belongs_to associations are automatically copied over, unless you are whitelisting attributes and forget to/ purposely don't add it there. For the rest of the associations you may have (i.e. has_one, has_many, has_and_belongs_to_many, has_many_through), you may use the `associations_for_cloning` method by passing in array of symbols.

**Note:** Any images or files you have will **not** be copied along, if you have included those relationships.

**Example**

```ruby
def associations_for_cloning
  [:aromas, :events]
end
```

## Fae Clone Button

You can use `fae_clone_button` in your list view tables to provide easy access to clone an item. Just pass in the item and the button will clone the object and take you to the newly created object's edit form.

```ruby
fae_clone_button item
```
