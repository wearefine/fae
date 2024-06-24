# Slack Notifications

Built around the `slack-notifier` gem, FAE now offers the ability to send a message to a Slack channel when an object is created or saved.

Add the Slack webhook URL(s) to your `fae.rb` file. It can be a single value, or comma separated for multiple:

```
# fae.rb
config.slack_webhook_url = ENV['SLACK_WEBHOOK_URL']
```

FAE's `base_model_concern.rb` has two new callbacks:

```ruby
after_create :notify_initiation
before_save :notify_changes
```

Models created with FAE's scaffold generators include this concern by default so you shouldn't need to take any action here.

However, there are a couple of new instance methods to drive this in your models:

```ruby
def notifiable_attributes
  # array of attributes to notify if changed e.g.:
  [:slug, :on_prod]
end
```


```ruby
def slack_message(field_name_symbol)
  case field_name_symbol
  when :on_prod
    status = self.on_prod? ? 'live' : 'not live'
    msg = ''
    msg += "#{Rails.application.class.module_parent_name} - "
    msg += "[#{name}](#{Rails.application.routes.url_helpers.edit_admin_wine_url(self)}) "
    msg += "(#{self.class.name.constantize}) is #{status} "
    msg += "#{field_name_symbol.to_s.gsub('_',' ')}"
    msg
  when :slug
    # Different message for slug changes.
  end
end
```

As illustrated, you can customize the messages as you wish.