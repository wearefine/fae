/* global Fae, multiSelect, fae_chosen */

/**
 * Fae form select
 * @namespace form.select
 * @memberof form
 */
Fae.form.select = {

  init: function() {
    this.multiselectOrChosen();
  },

  /**
   * Initialize multi select fields or regular select fields and add appropriate available/added item helper text
   */
  multiselectOrChosen: function() {
    var _this = this;
    var availableItemsStr = ' Available Items';
    var addedItemsStr = ' Added Items';

    /**
     * On selection change, update items left and currently added
     * @private
     */
    function updateMultiselectHeader() {
      var $instance = $(this)[0];
      $('.ms-selectable .custom-header').text( $instance.$selectableContainer.find($instance.elemsSelector).length + availableItemsStr);
      $('.ms-selection .custom-header').text( $instance.$selectionContainer.find($instance.elemsSelector).length + addedItemsStr);
    }

    $('select').each(function(index, elm){
      var $this = $(this);

      if ($this.hasClass('multiselect')) {
        $this.multiSelect({
          selectableHeader: '<div class="custom-header"></div>',
          selectionHeader: '<div class="custom-header"></div>',
          afterSelect: function(values) {
            updateMultiselectHeader.call(this);
          },
          afterDeselect: function(values) {
            updateMultiselectHeader.call(this);
          }
        });

        var selectableCount = $this.next('.ms-container').find('.ms-selectable li').not('.ms-selected').length
        var selectedCount = $this.next('.ms-container').find('.ms-selection .ms-selected').length;

        $('.ms-selectable .custom-header').text(selectableCount + availableItemsStr);
        $('.ms-selection .custom-header').text(selectedCount + addedItemsStr);

      } else {
        $this.fae_chosen();

      }
    });
  }

};
