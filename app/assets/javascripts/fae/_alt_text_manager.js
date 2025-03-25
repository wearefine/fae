
/* global Fae */

/**
 * Fae alt text manager
 * @namespace altTextManager
 */

Fae.altTextManager = {

  showBusy: function($button) {
    document.body.style.cursor = 'progress';
    $button.prop('disabled', true);
  },
  
  showReady: function($button) {
    document.body.style.cursor = 'default';
    $button.prop('disabled', false);
  },

  ready: function() {
    var emptyLabel = 'No alt text';
    var $editButton = $('.js-edit-alt-button');
    var $saveButton = $('.js-save-alt-button');
    var $cancelButton = $('.js-cancel-alt-button');
    var $generateButton = $('.js-generate-alt-button-on-alt-manager');
    $saveButton.hide();
    $cancelButton.hide();
    $generateButton.hide();
    
    $editButton.on('click', function() {
      $(this).siblings('.js-save-alt-button, .js-cancel-alt-button, .js-generate-alt-button-on-alt-manager').show();
      $(this).hide();
      var $altTextLabel = $(this).siblings('.js-alt-text-label');
      var $altTextInput = $(this).siblings('.js-alt-text-input');
      if ($altTextLabel.text() !== emptyLabel) {
        $altTextInput.val($altTextLabel.text());
      }
      $altTextLabel.hide();
      $altTextInput.show().focus();
    });
    
    $cancelButton.on('click', function() {
      var $this = $(this);
      $this.siblings('.js-edit-alt-button').show();
      $this.siblings('.js-save-alt-button, .js-generate-alt-button-on-alt-manager').hide();
      $this.hide();
      var $altTextLabel = $this.siblings('.js-alt-text-label');
      var $altTextInput = $this.siblings('.js-alt-text-input');
      $altTextInput.hide();
      $altTextLabel.show();
    });
    
    $saveButton.on('click', function() {
      var $this = $(this);
      var $altTextLabel = $this.siblings('.js-alt-text-label');
      var $altTextInput = $this.siblings('.js-alt-text-input');
      var value = $altTextInput.val();
      var url = 'alt_texts/' + $altTextInput.data('id') + '/update_alt';
      if(value !== emptyLabel) {
        $.post( url, { 'alt': value }, function() {
          $altTextLabel.text(value === '' ? emptyLabel : value);
        });
      }
      $altTextInput.hide();
      $altTextLabel.show();
      $this.hide();
      $this.siblings('.js-save-alt-button, .js-generate-alt-button-on-alt-manager, .js-cancel-alt-button').hide();
      $this.siblings('.js-edit-alt-button').show();
    });
    
    $generateButton.on('click', function (e) {
      e.preventDefault();
      var $this = $(this);
      var $altTextInput = $this.siblings('.js-alt-text-input');
      Fae.altTextManager.showBusy($this);
      $.ajax({
        url: `${Fae.path}/generate_alt?image_id=${$this.data('image-id')}`,
        type: 'POST',
        beforeSend: function(xhr) {
          xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        data: {
          image: e.target.result
        },
        success: function (response) {
          if (response.success) {
            $altTextInput.val(response.content);
          } else {
            alert(response.message);
          }
          Fae.altTextManager.showReady($this);
        }
      });
    });
  }
};