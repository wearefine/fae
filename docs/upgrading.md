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
