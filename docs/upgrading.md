# Upgrading Fae

[TOC]

---

# From v1.1 to v1.2

Fae v1.2 adds a new table `Fae::Change` to track changes on your objects. After updating you'll have to copy over and run the new migrations.

```bash
$ rake fae:install:migrations
$ rake db:migrate
```

---

# From v1.0 to v1.1

[View the CHANGELOG](https://bitbucket.org/wearefine/fae/src/master/CHANGELOG.md#markdown-header-11)

Fae v1.1 adds a new column to `Fae::User`. After upgrading you'll have to copy over the new migration and run it.

```bash
$ rake fae:install:migrations
$ rake db:migrate
```
