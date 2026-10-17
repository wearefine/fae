// Entry point for Fae's legacy (jQuery) admin JavaScript. `rake fae:js:build` resolves the requires below,
// with Sprockets, into the prebuilt app/assets/builds/fae_admin.js that ships with the gem. Run it after
// changing anything under app/legacy_js and commit the result.
//
// Libraries without a path under fae/ (jquery, jquery_ujs, jquery-ui, json2, judge, remotipart) come from gems.
// Order matters: later files rely on the globals the earlier ones define.

//= require jquery
//= require jquery_ujs
//= require jquery.remotipart
//= require jquery-ui/widgets/sortable
//= require jquery-ui/widgets/datepicker
//= require fae/vendor/underscore.min
//= require json2
//= require judge

//= require fae/vendor/chosen.jquery.min
//= require fae/vendor/frob_core_helpers
//= require fae/vendor/fryr
//= require fae/vendor/moment.min
//= require fae/vendor/jquery.daterangepicker
//= require fae/vendor/jqColorPicker.min
//= require fae/vendor/jquery.multi-select
//= require fae/vendor/jquery.simplemodal.1.4.4
//= require fae/vendor/jquery.tablesorter
//= require fae/vendor/js.cookie
//= require fae/vendor/touch_punch
//= require fae/vendor/simplemde/simplemde.min
//= require fae/vendor/simplemde/inline-attachment
//= require fae/vendor/simplemde/codemirror-4.inline-attachment
//= require fae/vendor/trumbowyg/trumbowyg
//= require fae/vendor/trumbowyg/plugins/upload/trumbowyg.upload

//= require fae/admin

//= require fae/form/hinter
//= require fae/form/_form
//= require fae/form/inputs/_dates
//= require fae/form/inputs/_color
//= require fae/form/inputs/_select
//= require fae/form/inputs/_text
//= require fae/form/inputs/_checkbox
//= require fae/form/_slugger
//= require fae/form/_validator
//= require fae/form/_cancel
//= require fae/form/_ajax
//= require fae/form/_ranked_select
//= require fae/form/_filtering
//= require fae/form/_form_manager
//= require fae/form/fae_chosen
//= require fae/form/fileinputer
//= require fae/form/drag_drop

//= require fae/navigation/sticky
//= require fae/navigation/_navigation
//= require fae/navigation/_subnav_highlighter
//= require fae/navigation/_language
//= require fae/navigation/_global_search

//= require fae/_modals
//= require fae/_tables
//= require fae/_alt_text_manager

//= require fae/fae_init
