# Fae Changelog

## Unreleased

- enhancements
    + Reorganize docs for easier access
    + Generated nested table controllers are now empty and inherit from `Fae::NestedBaseController`
    + \#57075: Add a flag to the install generator for internal usage
- bugs
    + Disabled checkboxes are now untouchable
    + Multiselect headers update available/added items accurately
    + \#57523: Remove errors after image is reuploaded

## 1.3

- enhancements
    + \#50420: Nested forms now accept custom titles
    + \#54683: Titleize names for forms
    + \#55066: Major HTML and SCSS refactor
    + \#55211: Change wording of "Replace Image" to be "Remove Image"
    + \#49891: Increase list efficiency by decreasing table cell height
    + \#55188: Add version and GitHub icon to footer on all pages
    + \#55067: Standardize regular column widths
    + \#46060: Tab no longer skips checkbox inputs
    + Add `fae_delete_button` helper method
    + \#54556: Add confirm dialogue before cloning
    + \#55186: Add global search feature
    + \#55864: Add gravatar
    + \#56040: Add tooltips to index table icons (clone and delete)
    + Add images and GIFs to documentation
    + \#56439: Consolidate initial install migrations
    + Rename sorting classes to be more clear and intuitive
    + \#55244: Add support toggle and sort support for scoped models
    + Add fae_sort_id view helper
    + \#52457: Allow diabling admin on specific environments
    + \#57073: Add options and documentation to generated initializer
    + \#52775: Ignore unhelpful Judge errors
    + \#56740: Allows fae_filter_form's block to be optional
- bugs
    + \#46537: Change root settings header to be 'Root Settings' and not 'Edit Option'
    + \#46157: Logo in root setting is no longer marked required
    + \#55752: YouTube helper image converted to display as a background image because of Sprockets compilation issue
    + \#55977: Fix positioning of smooth scroll on new models from nested forms
    + Rearrange assets to expose the Fae JS API and SCSS mixins/variables to parent apps
    + \#57119: Table columns can now be sorted after the table has been filtered
    + \#57071: Namespace vendor files within the Fae engine namespace

## 1.2.5

- enhancements
    + Added in the ability to pass a param to the new path in nested_table.
    + \#56793: add `slug_separator` option
- bugs
    + Updated change_item_link method so that it works w fae_display_fields that are integers not just strings.
    + Update hash-parsing library to Fryr and fix cookie/hash filtering on load
    + \#55502: clear carrierwave cache when deleteing an image to allow an image of the same name to be immediately viewable

## 1.2.4

- enhancements
    + \#50230: Check if Fae Roles have been created before recreating
    + Added in pattern in the documentation on configuring a Dynamic Relationship with a Page Model.
    + Added in documentation on configuring a conditionally required field.
    + Added in ability to pass view_helper#fae_content_form method options that you could give to any other simple form, and connected it to form_helper#fae_input
    + Added in helper_text option for nested_table
    + Changed fae_content_form from fae_input into more generic i.input to circumvent the additional methods and clear up an issue validations.
    + \#54548: Set on_prod to false when cloning
    + \#54625: use FINE logo as background to avoid the need to compile
    + Add Travis CI for testing

- bugs
    + \#53380: Don't link destroyed models in change tracker
    + \#50440: Persist checked state on nested forms
    + \#53410: Nav should open/close on current items too
    + \#48759: Index-page filters collapse beneath each other on overflow
    + Update docs with missing 'not' so it's clear assets aren't cloneable
    + \#54606: Update initial inject_into_file for routes to handle more variations of file's opening line.
    + \#54058: Replace accented characters with non-accented counterparts in slug generation
    + \#54619: Add slim as a gem dependency to support non FINE template apps
    + \#54169: Require jQuery in the engine
    + \#54608: Highlight next section on detail page's sub nav click
    + \#54608: Include `on_production` in live toggle attribute check
    + \#53749: Hide filters when no records are present
    + Fix rspec depreciation warnings

## 1.2.3

- enhancements
    + Update docs for github and prepare gem for release

## 1.2.2

- enhancements
    + \#52830: Add cancel button to nested forms
- bugs
    + \#52680: Add spacing between label and helper text on checkbox fields
    + \#51982: Vertical checkboxes should be vertical
    + \#52696: Remove image/file on replace image for nested forms too
    + Scope validations to current form to prevent main form from being validated on nested submission

## 1.2.1

- enhancements
    + \#51603: Add grouped  options to fae_filter_select
    + \#52306: Add activity icon for the activity log link
    + \#52801: Add validation styles and length support to simple-mde
- bugs
    + Support markdown WYSIWYG on fae_content_form
    + \#52730: fix bug that rebinds markdown everytime nested add button is clicked
    + \#51553: associate page images correctly to `Fae::StaticPage`
    + \#52588: Fallback to regular file input in IE9
    + \#52797: Use image size option to trigger image size validation error
    + \#52300: count newlines as two characters in character counter
    + \#52889: Resolve invalid url_regex Regex (reported by Judge's JS)
    + Make sure filtering selects don't overlap submit button
    + \#52646: Fix cloning issue when unique attributes also have a length validation

## 1.2

- enhancements
    + \#49965: Narrow width of color bar
    + \#50794: Industrial JavaScript refactor
    + \#40989: Add a configurable change tracker and activity log
    + Change jQuery cookie to vanilla JS cookie
    + \#45145: Save table sorting preferences during a single session
    + \#50785: When there's only one drawer on the page, do not allow drawers to toggle
    + \#49890: Haven't you always wanted to clone a record? Behold: object cloning
    + \#49896: Show error banner above the fold consistently
    + \#50905: Added super cool validation helpers
- bugs
    + \#48212: Adjust spacing on pages with multiple tables and drawers
    + \#51357: Add column's max length to string and text inputs
    + Fix AJAX response to accomodate uncompressed form HTML too
    + Remove spacing beneath tables (fixes improper nested table aesthetic)
    + fix col or field method in application helper so that it works properly with images in tables
    + fix added markdown init on add edit forms for nested tables

## 1.1.8

- enhancements
    + \#50863: Highlight nested nav items
- bugs
    + \#51042: mm/dd/yy sorting fix
    + fix @new_path implementation in header
    + fix Fae::StaticPage singleton setup check
    + fix responsive tables less than 768px
    + update nested scaffold generator to include routes and model concern
    + fix ordering on nested tables
    + \#51949: allow content exceeding character limit to be deleted
    + \#50108: Add length counter to AJAX'd fields if applicable

## 1.1.7

- enhancements
    + \#50855: Change default highlight color from blue to FINE green
    + \#50617: Enable validations for page content blocks
    + \#50795: Change dropdown default from 'Select a <singular>' to 'All <plural>'
    + \#49887: Standardize appearance of all gray buttons
- bugs
    + \#50863: Persist side navigation highlight when not on index
    + \#50779: File input label spacing shouldn't break to two lines without good cause
    + fix for nested tables, move header option to parent, not needed on child
    + fix JS validation not triggering on form submission
    + \#50786: Header new button should use local variable, not instance variable
    + \#50777: Tables should overflow on smaller screens
    + \#49823: Fixes first instances of Fae::StaticPage inhereited models always returning an instance of Fae::StaticPage

## 1.1.6

- enhancements
    + Add `config.recreate_versions` to initializer, to ensure conditional Carrierwave versions are created after attributes are save to the model
    + \#49400: Add plus icon to new item button
    + \#50224: Nested form functionality for indexes
    + \#49436: Added slugger functionality to nested tables
    + \#49408: Save filtered state in cookie
- bugs
    + \#48221: Increase padding on right textarea gutter
    + \#48215: Wrap helper text with input field; radio buttons go on their own line
    + \#50347: Fix extra long width for phone number fields
    + \#50383: Fix flickering when editing and adding multiple nested objects
    + \#50021: Fix Markdown supported" link-to-modal in nested forms
    + \#50108: Add validation to nested forms
    + \#50248: Allow text selection in tables

## 1.1.5

- enhancements
    + Add edit_column option to nested tables, defaulted to false, when true adds Edit link before Delete
    + Add breadcrumb_test option to header_form, defaulted to klass_name.titleize.pluralize
    + \#48664: Add ability to collapse tables on long pages
- bugs
    + \#48479: Update password confirmation message.
    + \#48479: Update required asteriks/label spacing for images to match other control fields.
    + \#48415: Updated nested table time format for date or time fields.
    + Updated postion feature so that Fae::Images model works with it.
    + Added width to column containing thumbnail, used when there isn't any text in the first column header after the position handle.
    + protect nil values on `fae_date_format` and `fae_datetime_format`
    + protect file size validation from exceptions in carrierwave/fog

## 1.1.4

- enhancements
    + \#47025: default fae_date_format is now (00/00/00), added fae_datetime_format to preserve long date with time
    + allows attached_as to be set in `fae_image_form`
- bugs
    + \#47025: make string inputs the same length as all other fields
    + added padding to the bottom of the main content section in case the last field of the form is a dropdown
    + fix for showing validation error on textarea blur, like inputs
    + fix datepicker for nested forms again, so it rebinds after the first add/update
    + wrap link text in span and add padding to prevent overflow when title is longer

## 1.1.3

- enhancements
    + \#47202: sticky table headers on scroll
- bugs
    + fixed checkbox style
    + allow date picker and date range picker to be utilized on nested forms
    + \#47628: fix ie9 JavaScript bug that was breaking all the things

## 1.1.2

- enhancements
    + allow thumbnails to show on nested tables
- bugs
    + fixed issue with ajax filtering
    + \#47229: default prompt now displays for belongs_to associations only
    + contain images to viewport

## 1.1.1

- bugs
    + \#46571: fixed select validations with Judge
    + \#46521: fixed checkbox bug
    + \#46725: fixed image deletion bug

## 1.1

- enhancements
    + \#45627: adds table filtering helpers
    + \#46094: adds language nav to support content in multiple languages
    + \#44624: Rails 4.2 support
    + \#45625: add export to csv for index pages
    + \#44718: added counter for fields with a max length.
    + \#46508: markdown helper text content updates
    + \#41106: set max image and file upload

- bugs
    + \#46839: fixed admin users not being able to add other users
    + \#46027: fixed validation date picker bug
    + \#46247: remove periods from slugs
    + \#46180: fix date range break on windows

## 1.0.4

- enhancements
    + added ability to use a select field with slugger
- bugs
    + \#46325: fixed ajax toggle vulnerability

## 1.0.3

- bugs
    + \#45917: image upload file path now wraps if too long

## 1.0.2

- enhancements
    + \#44577: add delete button back to file uploader
    + \#45147: update date range picker styles

## 1.0.1

- enhancements
    + organized SCSS to be more maintainable
- bugs
    + \#44810: fixes overlapping labels on image uploaders
    + \#40207: fixes table alignment

## 1.0

- EVERYTHING :tada:
