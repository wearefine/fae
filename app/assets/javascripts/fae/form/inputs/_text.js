/* global Fae, SimpleMDE, toolbarBuiltInButtons */

/**
 * Fae form text
 * @namespace form.text
 * @memberof form
 */
Fae.form.text = {
  init: function () {
    this.overrideMarkdownDefaults();
    this.initMarkdown();
    this.initHTML();
    this.initTranslation();
  },

  /**
   * Override SimpleMDE's preference for font-awesome icons and use a modal for the guide
   * @see {@link modals.markdownModal}
   */
  overrideMarkdownDefaults: function () {
    toolbarBuiltInButtons['bold'].className = 'icon-bold';
    toolbarBuiltInButtons['italic'].className = 'icon-italic';
    toolbarBuiltInButtons['heading'].className = 'icon-font';
    toolbarBuiltInButtons['code'].className = 'icon-code';
    toolbarBuiltInButtons['unordered-list'].className = 'icon-list-ul';
    toolbarBuiltInButtons['ordered-list'].className = 'icon-list-ol';
    toolbarBuiltInButtons['link'].className = 'icon-link';
    toolbarBuiltInButtons['image'].className = 'icon-image';
    toolbarBuiltInButtons['quote'].className = 'icon-quote';
    toolbarBuiltInButtons['fullscreen'].className = 'icon-fullscreen no-disable no-mobile';
    toolbarBuiltInButtons['horizontal-rule'].className = 'icon-minus';
    toolbarBuiltInButtons['preview'].className = 'icon-eye no-disable';
    toolbarBuiltInButtons['side-by-side'].className = 'icon-columns no-disable no-mobile';
    toolbarBuiltInButtons['guide'].className = 'icon-question';

    // Override SimpleMDE's default guide and use a homegrown modal
    toolbarBuiltInButtons['guide'].action = Fae.modals.markdownModal;
  },

  /**
   * Find all markdown fields and initialize them with a markdown GUI
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  initMarkdown: function () {
    var inlineAttachmentConfig = {
      uploadUrl: '/admin/html_embedded_image',
      uploadFieldName: 'image',
      jsonFieldName: 'file',
      progressText: '![Uploading file...]()',
      urlText: '![file]({filename})',
      errorText: 'Error uploading file, file may be too large',
      extraHeaders: {
        'X-CSRF-Token': $.rails.csrfToken()
      }
    }

    $('.js-markdown-editor:not(.mde-enabled)').each(function () {
      var $this = $(this);

      // set up translate button for markdown fields
      var $translateButton = $this.siblings( '.js-translate-button' )
      if ($translateButton.length > 0) {
        var labelHeight = $this.siblings( 'label' ).height()
        $this.siblings( '.js-translate-button' ).first().addClass('translate-markdown-button').css({
          'margin-top': labelHeight,
        });
      }

      var editor = new SimpleMDE({
        element: this,
        autoDownloadFontAwesome: false,
        status: false,
        spellChecker: false,
        hideIcons: ['image', 'side-by-side', 'fullscreen']
      });

      // added so we can access editor in translate text init
      $this.data({editor: editor});   
      
      inlineAttachment.editors.codemirror4.attach(editor.codemirror, inlineAttachmentConfig);

      // Disable tabbing within editor
      editor.codemirror.options.extraKeys['Tab'] = false;
      editor.codemirror.options.extraKeys['Shift-Tab'] = false;

      $this.addClass('mde-enabled');

      // code mirror events to hook into current form element functions
      editor.codemirror.on('change', function (){
        // updates the original textarea's value for JS validations
        $this.val(editor.value());
        // update length counter
        Fae.form.validator.length_counter.updateCounter($this);
      });
      editor.codemirror.on('focus', function (){
        $this.parent().addClass('mde-focus');
      });
      editor.codemirror.on('blur', function (){
        // trigger blur on the original textarea to trigger JS validations
        $this.blur();
        $this.parent().removeClass('mde-focus');
      });
    });
  },

  /**
   * Find all HTML fields and initialize them with a wysiwyg GUI
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  initHTML: function () {
    var $html_editors = $('.js-html-editor');
    if(!$html_editors.length) {
      return;
    }
    $html_editors.trumbowyg({
      btnsDef: {
        image: {
          dropdown: ['insertImage', 'upload', 'base64', 'noEmbed'],
          ico: 'insertImage'
        }
      },
      btns: [
        ['viewHTML'],
        ['undo', 'redo'],
        ['formatting'],
        'btnGrp-design',
        ['link'],
        ['image'],
        'btnGrp-justify',
        'btnGrp-lists',
        ['foreColor', 'backColor'],
        ['preformatted'],
        ['horizontalRule'],
        ['fullscreen']
      ],
      plugins: {
        upload: {
          serverPath: '/admin/html_embedded_image',
          fileFieldName: 'image'
        }
      },
      resetCss: true
    });
  },

    /**
   * Find all translate fields and initialize them with button
   */
    initTranslation: function () {
      // var $translate_button = $('.js-translate-button');
      $('.js-translate-button').click(function(e) {
        var $this = $(this);
        var translateField;

        // grab the field the button belongs to
        if ($this.closest(".text").length > 0) {
          translateField = this.closest(".text");
        } else  {
          translateField = this.closest(".string");
        }

        // grab language and model name from field, container logic is for image alt text
        var translateLanguage = translateField.attributes['data-language'].value;
        var translateModel;
        if (translateField.className.includes("container")) {
          translateModel = translateField.className.split(' ').reverse()[1];
        } else {
          translateModel = translateField.className.split(' ').pop();
        }

        // fix model name for static pages
        var n = translateModel.lastIndexOf('content');
        if (n) {
          translateModel = translateModel.slice(0, n) + translateModel.slice(n).replace('content', 'attributes_content');
        }
        // fix model name for image alt text
        var n = translateModel.lastIndexOf('_alt');
        if (n) {
          translateModel = translateModel.slice(0, n) + translateModel.slice(n).replace('_alt', '_attributes_alt');
        }

        // set english model name and use that to get text from english field
        var englishModel = translateModel.replace('_' + translateLanguage, '_en')
        var englishText = $('#' + englishModel)[0].value 

        // get translateLanguage in correct format for request
        if (translateLanguage.length == 4) {
          translateLanguage = `${translateLanguage.slice(0,2)}-${translateLanguage.slice(2)}`
        }

        $.ajax({
          url: Fae.path + '/translate_text',
          type: "post",
          beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
          data: { translation_text: { language: translateLanguage, en_text: englishText } },
          success: function(data) {
            if (data && data.length > 0) {
              if (data[0].error_text) {
                $(translateField)
                  .addClass('field_with_errors')
                  .append("<span class='error'>" + data[0].error_text + '</span>');
              } else if ($this.siblings('.CodeMirror').length > 0) {
                // set translation text into translate model for markdown fields
                const textArea = document.getElementById(translateModel)
                $(textArea).data('editor').value(data[0].translated_text)
              } else {
                // set translation text into translate model for non markdown fields
                $('#' + translateModel).val(data[0].translated_text);
              }
            }
          }
        })
      });

    }

};