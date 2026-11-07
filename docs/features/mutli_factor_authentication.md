# Mutli-Factor Authentication

Fae supports using one time passwords (OTP), via an authenticator app, to increase security to your app.

---

## Configure

The MFA feature uses ActiveRecord encrypted attributes. To set this up, first you must generate a key set. Run the following command in your command line.

```ruby
# Generates a random key set and outputs it to stdout
./bin/rails db:encryption:init
```

This should return something like the following:

```ruby
active_record_encryption:
  primary_key: Qw25fZjaxhxdWOKFyHjyKyYvVq9uA0Ga
  deterministic_key: FFSSjMQsRxWU4H1mH96JBW4o1HJF8wZ5
  key_derivation_salt: Vgo7V3USqaODX1Vn5H9HyHJmFGo7yEOA
```

Next add these values as the following environmental varables:

```ruby
  PRIMARY_KEY=Qw25fZjaxhxdWOKFyHjyKyYvVq9uA0Ga
  DETERMINISTIC_KEY=FFSSjMQsRxWU4H1mH96JBW4o1HJF8wZ5
  KEY_DERIVATION_SALT=Vgo7V3USqaODX1Vn5H9HyHJmFGo7yEOA
```

Finally, add the following to config/application.rb

```ruby
  config.active_record.encryption.primary_key = ENV["PRIMARY_KEY"]
  config.active_record.encryption.deterministic_key = ENV["DETERMINISTIC_KEY"]
  config.active_record.encryption.key_derivation_salt = ENV["KEY_DERIVATION_SALT"]
```

Once this is all done, go to '/admin/root' and check the `Multi-Factor Authentication Enabled?` field and save.  This will start the process of setting up mfa on your currently logged in account.

## Logging in

The login form only asks for an email and password. Users who have MFA set up are taken to a second step after their password is accepted, where they enter the code from their authenticator app (or one of their backup codes). Users without MFA are signed in straight away.

The MFA step expires after 5 minutes, after which the user has to start again from the login form. Invalid codes count toward the same lockout as invalid passwords (see `config.maximum_attempts` in the Devise initializer).

## Managing users

Admins and Super Admins have the ability to toggle the mfa feature for other users.  Going to `/admin/users`, the toggle titled `MFA Active` can deactivate or reactivate the MFA login requirements for individual users.  (NOTE: deactivating/reactivating MFA for a user does NOT retain their previous set up, causing them to have to set it up from scatch again.)

