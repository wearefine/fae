// /* global Fae */

// /**
//  * Fae form manager
//  * @namespace form
//  * @memberof Fae
//  */
// Fae.form.formManager = {

//   formData: null,
//   savedFieldSettings: null,
//   ignoreClasses: [],

//   init: function() {
//     this.onLoad();
//     this.events();
//   },

//   onLoad: function() {
//     var _this = this;
//     var $mainForm = $('form');

//     if($mainForm.length && $mainForm.attr('data-form-manager-info')) {
//       this.savedFieldSettings = JSON.parse($mainForm.attr('data-form-manager-info'));

//       $.each(JSON.parse(this.savedFieldSettings.fields), function(i, fieldSettings) {
//         _this._setupField(fieldSettings);
//         // if($.inArray(fieldSettings.containerClass, _this.ignoreClasses) === -1) {
//         //   _this._setupField(fieldSettings);
//         // }
//       });
//     }

//   },

//   events: function() {
//     var _this = this;

//     $('.js-launch-form-manager').click(function(e) {
//       e.preventDefault();

//       $('input').hide();
//       $('textarea').hide();
//       $('select').hide();
//       $('label').hide();
//       $('.counter').hide();
//       $('.markdown-support').hide();
//       $('.daterangepicker-seperator').hide();
//       $('.asset-inputs').hide();
//       $('.chosen-container').hide();
//       $('.ms-container').hide();
//       $('.editor-toolbar').hide();
//       $('.CodeMirror').hide();
//       $('.trumbowyg-box').hide();

//       $('.input').find('label:first').show().attr('contenteditable', true).css({"border": "1px solid red"});
//       $('label').find('h6').attr('contenteditable', true).css({"border": "1px solid blue"});

//       var $form = $(this).closest('form');
//       $('label').blur(function() {
//         //setTimeout(function(){
//           var payload = {
//             form_manager: {
//               form_manager_model_name: $form.data('form-manager-model'),
//               fields: {}
//             }
//           };
//           $.each($('[data-form_manager_id]'), function(i) {
//             var $container = $(this);
//             var formManagerId = $container.attr('data-form_manager_id');
//             var $label = $container.find('label:first');
//             var $labelTextEl = $label;
//             var $labelInner = $label.find('.label_inner');
//             if($labelInner.length) {
//               $labelTextEl = $labelInner;
//             }
//             var $helper = $label.find('h6');
//             var labelValue = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
//             var helperValue = $helper.text();
//             var requiredValue = $container.hasClass('required') ? 1 : 0;
//             payload.form_manager.fields[formManagerId] = {
//               formManagerId: formManagerId,
//               label: labelValue,
//               helper: helperValue,
//               required: requiredValue
//             };
//           });
//           console.log(payload);
//           $.post('/admin/form_managers/update', payload, function(data) {
//             //document.location.reload();
//           });
//         //}, 3000);
//       });
//       // _this.buildAndShowFormManagerFormOverlay.init();
//     });

//     $('.form-manager-container').on('click','.form-manager-submit', function(e) {
//       e.preventDefault();
//       _this.submitFormManagerForm();
//     });

//     $('.form-manager-container').on('click','.form-manager-cancel', function(e) {
//       e.preventDefault();
//       $('.main-content').show();
//       $('.form-manager').slideUp();
//       $('.form-manager-container').slideUp();
//     });
//   },

//   submitFormManagerForm: function() {
//     var $fmForm = $('#form-manager-form');
//     $.post($fmForm.attr('action'), $fmForm.serialize(), function(data) {
//       document.location.reload();
//     });
//   },

//   buildAndShowFormManagerFormOverlay: {
//     _this: null,
//     $formEl: $('<form />', {id: 'form-manager-form', action: '/admin/form_managers/update', class: 'form-manager'}),

//     init: function() {
//       this._this = Fae.form.formManager;

//       // if the form does not exist, build it
//       if ( !$('.form-manager').length ) {
//         this.$formEl
//           .append($('<header />', {class: 'content-header js-content-header js-will-be-sticky'})
//             .append($('<a />', {href: '#', text: 'Submit', class: 'form-manager-submit button'}))
//             .append($('<a />', {href: '#', text: 'Cancel', class: 'button form-manager-cancel'}))
//             )
//           .append($('<div />', {class: 'inner-content'})
//             .append($('<input />', {name: 'model_name', type: 'hidden', value: this._this.modelName}))
//             );
//         this.gatherAndInjectFields();
//       }

//       this._revealForm();
//     },

//     gatherAndInjectFields: function() {
//       var _this = this;

//       $.each($('[data-form_manager_id]'), function(i) {
//         _this.injectFieldIntoFormManager($(this));
//       });

//       _this._hideForm();
//       $('.form-manager-container').append(_this.$formEl);

//       $.each($('.table-add-link'), function(i) {
//         var $addLink = $(this);
//         var nestedType = $addLink.parent().parent().attr('id');

//         $.get($addLink.attr('href'), function(data) {
//           var $section = $('<section />', {class: 'content'});
//           var $h2 = $('<h2 />', {text: _this._this._titleize(nestedType.replace(/\_/g, ' '))});
//           _this.$formEl.append($section.append($h2));
//           $.each($(data).find('div.input'), function(i) {
//             _this.injectFieldIntoFormManager($(this));
//           });
//         });
//       });
//     },

//     injectFieldIntoFormManager: function($container) {
//       var _this = this;
//       var formManagerId = $container.attr('data-form_manager_id');
//       console.log($container.attr('data-form_manager_id'));
//       var $label = $container.find('.control-label');
//       var $labelTextEl = $label;
//       var $labelInner = $label.find('.label_inner');
//       if($labelInner.length) {
//         $labelTextEl = $labelInner;
//       }
//       console.log($labelTextEl);
//       var $helper = $label.find('h6');
//       // leave image and file utility inputs alone, and any field with _id in it, they don't need to override the labels of association fields.
//       if(true) {
//         var $fmFieldContainer = $('<div class="form-section" />');
//         var $fmSingleFieldContainer = $('<div class="single-field" />');
//         var $fmSingleHelperFieldContainer = $('<div class="single-field" />');
//         var $fmFieldTitle = $('<div class="field_title" />');
//         var $fmHelperFieldTitle = $('<div class="field_title" />');
//         var $fmFieldHeading = $('<label />', {text: _this._this._titleize(formManagerId.replace(/\_/g, ' '))});
//         var $fmHelperHeading = $('<label />', {text: "Helper Text", class: "helper"});

//         var labelValue = $labelTextEl.clone().children().remove().end().text().replace('*','').trim();
//         var helperValue = $helper.text();
//         if(_this._this.savedFieldSettings && _this._this.savedFieldSettings[formManagerId]) {
//           labelValue = _this._this.savedFieldSettings[formManagerId].label;
//           helperValue = _this._this.savedFieldSettings[formManagerId].helperText;
//         }
//         var $fmLabelInput = $('<input />', {name: _this._inputFieldName(formManagerId,'label'), type: 'text', value: labelValue, class: "field-input"});
//         var $fmHelperInput = $('<input />', {name: _this._inputFieldName(formManagerId,'helperText'), type: 'text', value: helperValue});

//         var $fmFieldRequiredInput = $('<input />', {name: _this._inputFieldName(formManagerId,'required'), type: 'hidden', value: $container.hasClass('required') ? 1 : 0});
//         var $fmShowFieldInput = $('<input />', {name: _this._inputFieldName(formManagerId,'show_field'), type: 'checkbox', value: 1, checked: $container.css('display') !== 'none', disabled: $container.hasClass('required')});


//         _this.$formEl.append(
//           $fmFieldContainer.append(
//             $fmSingleFieldContainer.append(
//               $fmFieldTitle.append(
//                 $fmFieldHeading,
//                 $fmShowFieldInput
//               ),
//               $fmLabelInput
//             ),
//             $fmSingleHelperFieldContainer.append(
//               $fmHelperFieldTitle.append(
//                 $fmHelperHeading
//               ),
//               $fmHelperInput,
//               $fmFieldRequiredInput
//             )
//           )
//         );
//       }
//     },

//     _inputFieldName: function(formManagerId,fieldName) {
//       return 'form_manager'+'['+formManagerId+']'+'['+fieldName+']';
//     },

//     _revealForm: function() {
//       $('.main-content').hide();
//       $('.form-manager-container').show();
//       $('.form-manager').fadeIn('fast');
//     },

//     _hideForm: function() {
//       $('.main-content').hide();
//     }
//   },

//   _setupField: function(fieldSettings) {
//     console.log(fieldSettings);
//     var $container = $('[data-form_manager_id="'+fieldSettings.formManagerId+'"]');
//     if($container.length) {
//       var $label = $container.find('label:first');
//       var $labelInner = $label.find('.label_inner');
//       var $labelTextEl = $label;
//       if($labelInner.length) {
//         $labelTextEl = $labelInner;
//       }

//       //var $labelsCheckbox = $labelTextEl.find('input');

//       var existingLabelText = $labelTextEl.html();
//       var newLabelText = '';
//       if($container.hasClass('required')) {
//         newLabelText = '<abbr title="required">*</abbr> ';
//       }

//       newLabelText += fieldSettings.label;
//       $labelTextEl.html(newLabelText);
//       // if($labelsCheckbox.length) {
//       //   $labelTextEl.append($labelsCheckbox);
//       // }
//       if(fieldSettings.helper) {
//         $label.find('h6').remove();
//         $label.append($('<h6 />', {class: 'helper_text'}).text(fieldSettings.helper));
//       }

//       if(fieldSettings.show_field === 0) {
//         $container.hide();
//       }
//     }
//   },

//   _capitalize: function(string) {
//     return string.charAt(0).toUpperCase() + string.slice(1);
//   },

//   _titleize: function(string) {
//     var _this = this;
//     var string_array = string.split(' ');
//     string_array = string_array.map(function(str) {
//        return _this._capitalize(str);
//     });
//     return string_array.join(' ');
//   }

// };