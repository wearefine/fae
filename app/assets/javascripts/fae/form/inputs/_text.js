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

      var translate_button = $this.siblings( '.js-translate-button' )
      if (translate_button.length) {
        var label = $this.siblings( 'label' )
        var label_height = $this.siblings( 'label' ).height()
        $this.siblings( '.js-translate-button' ).closest(".input").css({
          'display': 'block',
          'position': 'relative'
        });
        $this.siblings( '.js-translate-button' ).first().css({
          'top': `10px`,
          'margin-top': label_height,
          'position': 'absolute',
          'margin-left': '10px',
          'right': 0,
          'transform': 'translateX(calc(100% + 10px'
        });
      }
      

      var editor = new SimpleMDE({
        element: this,
        autoDownloadFontAwesome: false,
        status: false,
        spellChecker: false,
        hideIcons: ['image', 'side-by-side', 'fullscreen']
      });

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
        var translate_field;

        // grab the field the button belongs to
        if (this.closest(".text")) {
          translate_field = this.closest(".text");
        } else  {
          translate_field = this.closest(".string");
        }

        // grab language and model name from field
        var translate_language = translate_field.attributes['data-language'].value;
        var translate_model = translate_field.className.split(' ').pop();

        // fix model name for static pages
        if (translate_model.lastIndexOf('content')) {
          var n = translate_model.lastIndexOf('content');
          translate_model = translate_model.slice(0, n) + translate_model.slice(n).replace('content', 'attributes_content');
        }

        // set english model name and use that to get text from english field
        var english_model = translate_model.replace('_' + translate_language, '_en')
        var english_text = $('#' + english_model)[0].value 

        // get translate_language in correct format for request
        if (translate_language.length == 4) {
          translate_language = `${translate_language.slice(0,2)}-${translate_language.slice(2)}`
        }

        $.ajax({
          url: Fae.path + '/translate_text',
          type: "post",
          data: { translation_text: { language: translate_language, en_text: english_text } },
          success: function(data) {
            // set translation text into tranlate model
            if ($this.siblings('.CodeMirror').length) {
              const textArea = document.getElementById(translate_model)
              $(textArea).data('editor').value(data[0].translated_text)
            } else {
              $('#' + translate_model).val(data[0].translated_text);
            }
          },
          error: function(data) {
            // Not sure what to put here
            console.log(data)
          }
        })
      });

    }

};