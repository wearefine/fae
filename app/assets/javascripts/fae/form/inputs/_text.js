/* global Fae, SimpleMDE, toolbarBuiltInButtons */

/**
 * Fae form text
 * @namespace form.text
 * @memberof form
 */
Fae.form.text = {
  init: function() {
    this.overrideMarkdownDefaults();
    this.initMarkdown();
    this.initHTML();
  },

  /**
   * Override SimpleMDE's preference for font-awesome icons and use a modal for the guide
   * @see {@link modals.markdownModal}
   */
  overrideMarkdownDefaults: function() {
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
  initMarkdown: function() {
    $('.js-markdown-editor:not(.mde-enabled)').each(function() {
      var $this = $(this);

      var editor = new SimpleMDE({
        element: this,
        autoDownloadFontAwesome: false,
        status: false,
        spellChecker: false,
        hideIcons: ['image', 'side-by-side', 'fullscreen', 'preview']
      });

      // Disable tabbing within editor
      editor.codemirror.options.extraKeys['Tab'] = false;
      editor.codemirror.options.extraKeys['Shift-Tab'] = false;

      $this.addClass('mde-enabled');

      // code mirror events to hook into current form element functions
      editor.codemirror.on('change', function(){
        // updates the original textarea's value for JS validations
        $this.val(editor.value());
        // update length counter
        Fae.form.validator.length_counter.updateCounter($this);
      });
      editor.codemirror.on('focus', function(){
        $this.parent().addClass('mde-focus');
      });
      editor.codemirror.on('blur', function(){
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
  initHTML: function() {
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
  }
};
