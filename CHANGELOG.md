# Fae Changelog

## Unreleased

- enhancements
- bugs
    + Updated postion feature so that Fae::Images model works with it.
    + Added width to column containing thumbnail, used when there isn't any text in the first column header after the position handle.
    + protect nil values on `fae_date_format` and `fae_datetime_format`

## 1.1.4

- enhancements
    + [#47025](https://issues.afinedevelopment.com/issues/47025): default fae_date_format is now (00/00/00), added fae_datetime_format to preserve long date with time
    + allows attached_as to be set in `fae_image_form`
- bugs
    + [#47025](https://issues.afinedevelopment.com/issues/47025): make string inputs the same length as all other fields
    + added padding to the bottom of the main content section in case the last field of the form is a dropdown
    + fix for showing validation error on textarea blur, like inputs
    + fix datepicker for nested forms again, so it rebinds after the first add/update
    + wrap link text in span and add padding to prevent overflow when title is longer

## 1.1.3

- enhancements
    + [#47202](https://issues.afinedevelopment.com/issues/47202): sticky table headers on scroll
- bugs
    + fixed checkbox style
    + allow date picker and date range picker to be utilized on nested forms
    + [#47628](https://issues.afinedevelopment.com/issues/47628): fix ie9 JavaScript bug that was breaking all the things

## 1.1.2

- enhancements
    + allow thumbnails to show on nested tables
- bugs
    + fixed issue with ajax filtering
    + [#47229](https://issues.afinedevelopment.com/issues/47229): default prompt now displays for belongs_to associations only
    + contain images to viewport

## 1.1.1

- bugs
    + [#46571](https://issues.afinedevelopment.com/issues/46571): fixed select validations with Judge
    + [#46521](https://issues.afinedevelopment.com/issues/46521): fixed checkbox bug
    + [#46725](https://issues.afinedevelopment.com/issues/46725): fixed image deletion bug

## 1.1

- enhancements
    + [#45627](https://issues.afinedevelopment.com/issues/45627): adds table filtering helpers
    + [#46094](https://issues.afinedevelopment.com/issues/46094): adds language nav to support content in multiple languages
    + [#44624](https://issues.afinedevelopment.com/issues/45625): Rails 4.2 support
    + [#45625](https://issues.afinedevelopment.com/issues/45625): add export to csv for index pages
    + [#44718](https://issues.afinedevelopment.com/issues/44718): added counter for fields with a max length.
    + [#246508](https://issues.afinedevelopment.com/issues/246508): markdown helper text content updates
    + [#41106](https://issues.afinedevelopment.com/issues/41106): set max image and file upload

- bugs
    + [#46839](https://issues.afinedevelopment.com/issues/46839]): fixed admin users not being able to add other users
    + [#46027](https://issues.afinedevelopment.com/issues/46027]): fixed validation date picker bug
    + [#46247](https://issues.afinedevelopment.com/issues/46247): remove periods from slugs
    + [#46180](https://issues.afinedevelopment.com/issues/46180): fix date range break on windows

## 1.0.4

- enhancements
    + added ability to use a select field with slugger
- bugs
    + [#46325](https://issues.afinedevelopment.com/issues/46325): fixed ajax toggle vulnerability

## 1.0.3

- bugs
    + [#45917](https://issues.afinedevelopment.com/issues/45917): image upload file path now wraps if too long

## 1.0.2

- enhancements
    + [#44577](https://issues.afinedevelopment.com/issues/44577): add delete button back to file uploader
    + [#45147](https://issues.afinedevelopment.com/issues/45147): update date range picker styles

## 1.0.1

- enhancements
    + organized SCSS to be more maintainable
- bugs
    + [#44810](https://issues.afinedevelopment.com/issues/44810): fixes overlapping labels on image uploaders
    + [#40207](https://issues.afinedevelopment.com/issues/40207): fixes table alignment

## 1.0

- EVERYTHING :tada:
