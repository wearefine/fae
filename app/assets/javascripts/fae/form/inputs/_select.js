/* global Fae, multiSelect, fae_chosen */

'use strict';

Fae.form.select = {

  init: function() {
    this.selectableText();
    this.multiselectOrChosen();
  },

  availableItemsStr: ' Available Items',
  addedItemsStr: ' Added Items',

  multiselectOrChosen: function() {
    $('select').each(function(index, elm){
      var $this = $(this);

      if( $this.hasClass('multiselect') ) {
        $this.multiSelect({
          selectableHeader: '<div class="custom-header"></div>',
          selectionHeader: '<div class="custom-header"></div>'
        });

        var selectableCount = $this.next('.ms-container').find('.ms-selectable li').not('.ms-selected').length
        var selectedCount = $this.next('.ms-container').find('.ms-selection .ms-selected').length;

        $('.ms-selectable .custom-header').text(selectableCount + this.availableItemsStr);
        $('.ms-selection .custom-header').text(selectedCount + this.addedItemsStr);

      } else {
        $this.fae_chosen();

      }
    });
  },

  selectableText: function() {
    var $selectable = $('.ms-selectable .custom-header');
    var $selection = $('.ms-selection .custom-header');

    $('.ms-selectable li').on('click', function(){
      $selectable.text(parseInt($selectable.text()) -1 + this.availableItemsStr);
      $selection.text(parseInt($selection.text()) +1 + this.addedItemsStr);
    });

    $('.ms-selection li').on('click', function(){
      $selectable.text(parseInt($selectable.text()) + 1 + this.availableItemsStr);
      $selection.text(parseInt($selection.text()) -1 + this.addedItemsStr);
    });

  }

};
