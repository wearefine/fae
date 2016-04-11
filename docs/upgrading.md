# Upgrading Fae

* [From v1.1 to v1.2](#from-v11-to-v12)
* [From v1.0 to v1.1](#from-v10-to-v11)

---

# From v1.1 to v1.2

Fae v1.2 adds a new table `Fae::Change` to track changes on your objects. After updating you'll have to copy over and run the new migrations.

```bash
$ rake fae:install:migrations
$ rake db:migrate
```

---

# From v1.0 to v1.3

Fae v1.3 consolidates install migrations. When upgrading from v1.0 to v1.3 <=, Fae will have to be [upgraded to v1.1 and have the new migrations copied](#from-v10-to-v11):

After a successful migration, follow any [additional upgrading steps](#from-v11-to-v12) before proceeding. For more information, please see [the migration consolidation PR](https://github.com/wearefine/fae/pull/84).

---

# From v1.0 to v1.1

[View the CHANGELOG](changelog.md#markdown-header-11)

Fae v1.1 adds a new column to `Fae::User`. After upgrading you'll have to copy over the new migration and run it.

```bash
$ rake fae:install:migrations
$ rake db:migrate
```
