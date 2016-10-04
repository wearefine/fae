# Global Search

Fae features a global search/navigation in the upper right. Clicking on this will automatically display the first two levels of navigation. Search results will be displayed from both navigation items and DB objects when three characters or more are entered in the search bar.

Navigation items are matched by their defined titles, ignoring case. Objects are matched by their `fae_display_field`.

## Omitting an Object

To omit an object from global search, add it to the `dashboard_exclusions` array in `config/initializers/fae.rb`

```ruby
config.dashboard_exclusions = %w( Cat )
```