# Fae Styles

## Collapsible tables

![Collapsible](https://raw.githubusercontent.com/wearefine/fae/master/docs/images/collapsible.gif)

Some pages have multiple tables that are easier to navigate if tables can be shown or hidden. Wrap each table in a `.collapsible` div and prepend an `h3` with the item's name and count. Example below and on the dummy app's `events/index` page.

```slim
main.content
  .collapsible
    h3 All Wine (#{@all_wine.length})
    table
      // ....
  .collapsible
    h3 White & Sparkling Wine (#{@white_sparkling_wine.length})
    table
      // ....
```

For best results, include an Open/Close All toggle.

```slim
main.content
  .collapsible-toggle Open All
  .collapsible
    // ....
```

To have all collapsible tables state, update the toggle text and add an `.active` class.

```slim
main.content
  .collapsible-toggle Close All
  .collapsible.active
    h3 All Wine (#{@all_wine.length})
    table
      // ....
```
