# JavaScript Standards

## Functions

camelCase

### Access

Methods used only within the namespace should be preceeded by an underscore. This denotes the equivalent of Ruby's `private` even those these functions are still publicly exposed.

## Variables

snake_case

### References

When referencing upper namespace, always use `_this`. `that` will not be tolerated.

### jQuery objects

Preceed all things jQuery with a `$`.