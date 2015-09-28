/* global Fae, multiSelect, fae_chosen */

'use strict';

/**
 * Fae form select
 * @namespace
 */
Fae.form.select = {

  availableItemsStr: ' Available Items',
  addedItemsStr: ' Added Items',

  init: function() {
    this.selectableText();
    this.multiselectOrChosen();
  },

  /**
   * Initialize multi select fields or regular select fields and add appropriate available/added item helper text
   */
  multiselectOrChosen: function() {
    var _this = this;

    $('select').each(function(index, elm){
      var $this = $(this);

      if ($this.hasClass('multiselect')) {
        $this.multiSelect({
          selectableHeader: '<div class="custom-header"></div>',
          selectionHeader: '<div class="custom-header"></div>'
        });

        var selectableCount = $this.next('.ms-container').find('.ms-selectable li').not('.ms-selected').length
        var selectedCount = $this.next('.ms-container').find('.ms-selection .ms-selected').length;

        $('.ms-selectable .custom-header').text(selectableCount + _this.availableItemsStr);
        $('.ms-selection .custom-header').text(selectedCount + _this.addedItemsStr);

      } else {
        $this.fae_chosen();

      }
    });
  },

  /**
   * On selection change, update items left and currently added
   */
  selectableText: function() {
    var _this = this;
    var $selectable = $('.ms-selectable .custom-header');
    var $selection = $('.ms-selection .custom-header');

    $('.ms-selectable li').on('click', function(){
      $selectable.text( (parseInt($selectable.text()) - 1) + _this.availableItemsStr );
      $selection.text( (parseInt($selection.text()) + 1) + _this.addedItemsStr );
    });

    $('.ms-selection li').on('click', function(){
      $selectable.text( (parseInt($selectable.text()) + 1) + _this.availableItemsStr );
      $selection.text( (parseInt($selection.text()) - 1) + _this.addedItemsStr );
    });

  }

};
