# Fae Changelog

## 2.1

- enhancements
    + Add GraphQL support [#475](https://github.com/wearefine/fae/pull/475)
    + Add I18n support for the admin interface [#434](https://github.com/wearefine/fae/pull/434)
    + Update Carrierwave whitelist method naming [#470](https://github.com/wearefine/fae/pull/470)
    + Make user edit and my settings view more consistent [#473](https://github.com/wearefine/fae/pull/473)
    + Update Devise to latest version [#465](https://github.com/wearefine/fae/pull/465)
    + Add Rails versions to dummy migrations [#463](https://github.com/wearefine/fae/pull/463)
- bugs
    + Fix user settings cancel path [#476](https://github.com/wearefine/fae/pull/476)
    + Force adding route via generator if it already exists [#471](https://github.com/wearefine/fae/pull/471)
    + Init HTML editors when AJAX loads forms [#460](https://github.com/wearefine/fae/pull/460)
    + Fix bugs in stripValidation() [#426](https://github.com/wearefine/fae/pull/426)
    + Nested ajax form fixes for file attachment fields [#421](https://github.com/wearefine/fae/pull/421)
    + Selects need initing for nested forms so we can have select all, etc [#430](https://github.com/wearefine/fae/pull/430)
    + Fix colour picker when sidenav present [#413](https://github.com/wearefine/fae/pull/413)
    + Fix nested AJAX form validations [#419](https://github.com/wearefine/fae/pull/419)
    + Only define StaticPage validations on Fae::TextField and Fae::TextArea [#418](https://github.com/wearefine/fae/pull/418)
- documentation
    + Test and document fae_translate on Fae::StaticPage [#472](https://github.com/wearefine/fae/pull/472)
    + Fix languages selector attribute in shared form headers documentation [#444](https://github.com/wearefine/fae/pull/444)
    + Fix typos in documentation [#459](https://github.com/wearefine/fae/pull/459)
    + Update custom image docs [#438](https://github.com/wearefine/fae/pull/438)
    + Update custom image docs [#420](https://github.com/wearefine/fae/pull/420)
    + Minor docs fix [#417](https://github.com/wearefine/fae/pull/417)
    + Clarifying supported Rails versions in README [#412](https://github.com/wearefine/fae/pull/412)

## 2.0

- enhancements
    + Add Rails 5.1 and 5.2 support
    + Consolidate `form_header` partial [#342](https://github.com/wearefine/fae/pull/342)
    + Rename translate to fae_translate to avoid conflicts [#375](https://github.com/wearefine/fae/pull/375)
    + Add quickstart content to dashboard [#379](https://github.com/wearefine/fae/pull/379)
    + Update gem dependency versions [#395](https://github.com/wearefine/fae/pull/395)
    + Add Rails version to migrations [#396](https://github.com/wearefine/fae/pull/396)
    + Make polymorphic assets optional as required by Rails 5.1+ [#402](https://github.com/wearefine/fae/pull/402)
    + Small content fixes [#403](https://github.com/wearefine/fae/pull/403)
- bug fixes
    + Allow integers to be passed through nested table columns [#405](https://github.com/wearefine/fae/pull/405)
- deprecations
    + Deprecate Rails 4 support [#338](https://github.com/wearefine/fae/pull/338)
    + Deprecate <1.3 markup ([#332](https://github.com/wearefine/fae/pull/332), [#343](https://github.com/wearefine/fae/pull/343))
    + Deprecate attr_toggle in favor of fae_toggle [#355](https://github.com/wearefine/fae/pull/355)

## 1.7.1

- enhancements
    + Add Simplified Chinese translations [#359](https://github.com/wearefine/fae/pull/359)
    + Update carrierwave, rmagick and kaminari dependencies [#380](https://github.com/wearefine/fae/pull/380)
    + Better documentation for dynamic relationships on static pages [#363](https://github.com/wearefine/fae/pull/363)
- bug fixes
    + Prevent duplicate submissions on nested forms [#383](https://github.com/wearefine/fae/pull/383)
    + `fae_display_field` is supposed to be scoped to the instance not the class [#374](https://github.com/wearefine/fae/pull/374)

## 1.7

- enhancements
    + Add color picker form helper [#345](https://github.com/wearefine/fae/pull/345)
    + Decouple pagination from filters [#328](https://github.com/wearefine/fae/pull/328)
    + Allow blank labels for fae_content_form [#360](https://github.com/wearefine/fae/pull/360)
    + Resolve Sass warnings about extending compound selectors [#349](https://github.com/wearefine/fae/pull/349)
    + Add support for decorator pattern [#361](https://github.com/wearefine/fae/pull/361)
    + Documentation for language, Heroku, and files [#331](https://github.com/wearefine/fae/pull/331)
    + Document specify static_page association as optional [#356](https://github.com/wearefine/fae/pull/356)
    + Remove test_files from gemspec [#357](https://github.com/wearefine/fae/pull/357)
- bug fixes
    + Wait for all validation checks to complete before submitting form [#335](https://github.com/wearefine/fae/pull/335)
    + Don't assume objects for cloning have on_prod attr [#330](https://github.com/wearefine/fae/pull/330)
    + Remove include_blank duplicate [#346](https://github.com/wearefine/fae/pull/346)
    + Show action returns a 404 by default [#339](https://github.com/wearefine/fae/pull/339)
    + Style flash message errors appropriately [#333](https://github.com/wearefine/fae/pull/333)
    + Documentation formatting & vulnerability update [#358](https://github.com/wearefine/fae/pull/358)

## 1.6

- enhancements
    + Add HTML wysiwyg editor with image upload [#224](https://github.com/wearefine/fae/issues/224)
    + Add JSON support for Fae::StaticPage [#249](https://github.com/wearefine/fae/issues/249)
    + Left-nav refresh & compatibility w/ legacy admin markup [#300](https://github.com/wearefine/fae/issues/300)
    + Add "Select All" and "Deselect All" options to multiselect [#299](https://github.com/wearefine/fae/issues/299)
    + Small style updates [#236](https://github.com/wearefine/fae/issues/236)
    + Add documentation for row sorting feature [#239](https://github.com/wearefine/fae/issues/239)
    + Update local setup docs [#242](https://github.com/wearefine/fae/issues/242)
    + Test suite improvements [#247](https://github.com/wearefine/fae/issues/247)
    + Change handling of saved filter state to allow deep links to override saved cookie filter settings on load, but not overwrite them in the cookie [#263](https://github.com/wearefine/fae/issues/263)
    + Nested table H3s have been promoted to H2s to increase their visiblity on long detail pages [#268](https://github.com/wearefine/fae/issues/268)
    + Update default alt helper text [#277](https://github.com/wearefine/fae/issues/277)
    + Don't show the Fae namespace in activity log model names [#284](https://github.com/wearefine/fae/issues/284)
    + Remove "Fae" in activity log [#297](https://github.com/wearefine/fae/issues/297)
    + Allow assets to be cloneable [#286](https://github.com/wearefine/fae/issues/286)
    + Ruby 2.4 compatibility [#282](https://github.com/wearefine/fae/issues/282)
    + Clean up login form CSS [#291](https://github.com/wearefine/fae/issues/291)
    + Remove attribute or association requirement on fae_suffix/prefix [#301](https://github.com/wearefine/fae/issues/301)
    + Add Travis CI integration [#306](https://github.com/wearefine/fae/issues/306)
    + Add tutorial for integrating Devise and Fae [#307](https://github.com/wearefine/fae/issues/307)
- bugs
    + Fix typo in Tutorials navigation [#237](https://github.com/wearefine/fae/issues/237)
    + Do not assume there are html editors present for trumbowyg to act upon [#248](https://github.com/wearefine/fae/issues/248)
    + Automatically set role position for new roles [#244](https://github.com/wearefine/fae/issues/244)
    + Remove appended input label from validation errors [#251](https://github.com/wearefine/fae/issues/251)
    + Fix titleization of nested form headings [#264](https://github.com/wearefine/fae/issues/264)
    + Fix search form clearing [#267](https://github.com/wearefine/fae/issues/267)
    + Fix Rails 5.1 deprecation warnings [#273](https://github.com/wearefine/fae/issues/273)
    + Call unique_changeable_types on class not item set [#279](https://github.com/wearefine/fae/issues/279)
    + Authorize global search results [#285](https://github.com/wearefine/fae/issues/285)
    + Fix file size validator bug [#278](https://github.com/wearefine/fae/issues/278)
    + Use head instead of render in delete_image [#310](https://github.com/wearefine/fae/issues/310)
    + Assign initializer settings from Fae after initialization [#313](https://github.com/wearefine/fae/issues/313)
    + Block POSTs to first_user if a super admin already exists [#320](https://github.com/wearefine/fae/issues/320)

## 1.5.1

- enhancements
    + Update dynamic relationships docs for pages and split out to make easier to find
    + Resolve Rails 5 depreciation warnings [#167](https://github.com/wearefine/fae/issues/167)
    + Support `config.action_controller.include_all_helpers = false` [#227](https://github.com/wearefine/fae/issues/227)
    + Should not singularize page class name [#210](https://github.com/wearefine/fae/pulls/210)
- bugs

## 1.5

- enhancements
    + Rails 5 support
    + \#52299: Adds caching system
    + \#62472: Add keyboard support to form checkboxes
    + \#62473: Ensure focus styles exist for all form elements
    + \#64544: Update focus and success form field borders
    + \#61840: Document markdown overriding process
    + \#64653: Refresh sidebar navigation styles
    + \#57081: Change relevant instances of .humanize to .titleize
    + \#60891: Add generator support for :image and :file attachments
    + \#60892: Add Fae::BaseModelConcern class methods has_fae_image and has_fae_file for shorthand image/file attachment definitions
    + \#64645: Restore display of left navigation on form pages
    + \#61113: Improved helper text for Fae settings logo image
    + \#65595: Add standard image alt helper text that can be overridden
- bugs
    + \#65689: Adds CSRF protection
    + Checks for use_pagination method on filter action
    + Fixes filter form variable
    + Add .js-results-table class back so activity log page's table can be properly targeted
    + Bump acts_as_list to ~> 0.9.0 to avoid rails 5 deprecation errors
    + \#60176: Format strange ActiveSupport::TimeWithZone datatypes as 00/00/00, default classes, change 'Updated At' to 'Modified', add -action-narrow for date time formatting on two lines.
    + Kaminari/Rails 5 compatibility [#184](https://github.com/wearefine/fae/issues/184)
    + Sets StaticPage associations to not be readonly [#138](https://github.com/wearefine/fae/issues/138)
- deprecations
    + \#65539: gracefully deprecate `has_top_nav`, top navigation is the standard

## 1.4.1

- enhancements
    + Adds support for "js-results-table" utility class for filtered results AJAX targeting
- bugs
    + \#60596: Add helper + CSS for displaying images in list views
    + \#61975: Add bottom border to table rows
    + \#61164: Colorize form section headings per $c-custom-highlight
    + \#60581: Tighten input display by displaying helper text to the right of labels
    + \#60547: Tighten vertical padding of list view rows
    + \#59915: Tighten default column widths on list views
    + \#59343: Add drop-up support for select boxes at bottom of viewport. Increase default height of drop menus
    + \#61163: Resolve issue with sortable theads not reacting to user input
    + \#60184: Min-height is no longer added to last form section referenced in form subnav
    + \#60184: Tighten default padding of form inputs and sections
    + \#61045: Ensure max-height of asset preview within image uploader
    + Fix bug in activity log paging where certain cases or Kaminari's page object won't convert to a page number
    + \#60183: Resolive issue with smaller images in popup rendering microscopic due to padding.
    + \#60923: Widen hint model for video url helper
    + \#60433: Adds flash messages to dashboard
    + \#61096: Adds warning notification style, apply to cancel message
    + Fix for_fae_index issue, since it's an override-able method
    + Fix bug in content_form that prevented custom input_classes

## 1.4

- enhancements
    + Add custom authorization levels
    + \#55333: Add pagination 📖
    + Add concern extension capability to `Fae::Change`
    + Tables now indicate to user something is happening when filtering
    + Add fae_tracker_parent to track child model changes in parent tracked changes list
- bugs
    + Added in a base controller method to enable/disable pagination per controller.
    + \#59273: Remove header on nested tables
    + \#59473: Reinitialize form elements on redrawing of nested forms
    + \#59386: Show sub page indicator as "open" when landing on an active view
    + \#58752: Languages should load from previously selected preference
    + Default language on static pages should be the first defined
    + Set language to English for Admin side to prevent translation attempt when locale other than English has been set on the frontend
    + Restrict markdown helper to modal content

## 1.3.1

- enhancements
    + Titleize rather than Capitalize for generated TH labels
    + Reorganize docs for easier access
    + Generated nested table controllers are now empty and inherit from `Fae::NestedBaseController`
    + \#57075: Add a flag to the install generator for internal usage
    + Support multiple languages on static page fields
    + \#57288: main nav items will display the paths of the first drop down item by default
    + Add `translate` class method for easy attribute lookup/retrieval
- bugs
    + Disabled checkboxes are now untouchable
    + Multiselect headers update available/added items accurately
    + \#57523: Remove errors after image is reuploaded
    + \#57772: Link admin logo to parent app root path
    + Force `fae_display_field` to be a string when using the front-end search
    + \#57772: Revert admin logo linking (now links to admin root path)
    + \#58411: Remove "Add Page" from pages#index

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