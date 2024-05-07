
/* global Fae */

/**
 * Fae alt text manager
 * @namespace altTextManager
 */

Fae.altTextManager = {

  ready: function() {
    console.log('alt text manager ready');
    var originalValue = null;
    var emptyLable = 'No alt text';
    var $altTextLabel = $('.alt_text_label');
    var $altTextInputs = $('.alt_text_input');

    $('body').on('click', '.alt_text_label', function() {
      $altTextInputs.hide();
      $altTextLabel.show();
      var $label = $(this);
      var $input = $label.next('textarea');
      var value = $label.text();

      if(value !== emptyLable) {
        $input.val(value);
        originalValue = value;
      }

      $label.hide();
      $input.show().focus();
    });

    $('body').on('blur', '.alt_text_input', function() {
      var $input = $(this);
      var $label = $input.prev('span');
      var value = $input.val();
      var id = $input.data('id');
      var url = 'alt_texts/' + id + '/update_alt';

      if(value !== originalValue || value !== emptyLable) {
        $.post( url, { 'alt': value }, function() {
          $label.text(value === '' ? emptyLable : value);
        });
      }

      $input.hide();
      $label.show();
    });
  }

};

