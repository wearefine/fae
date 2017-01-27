/* global Fae, multiSelect, fae_chosen */

/**
 * Fae form select
 * @namespace form.select
 * @memberof form
 */
Fae.form.select = {

  init: function() {
    this.multiselectOrChosen();
    this.multiselectChosenActions();
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
  },

  /**
   * TODO: Create a more extensible solution allowing for various actions to be attached to a Chosen multiselect.
   */
  multiselectChosenActions: function() {
    var input_select = '.input.select';
    var $eligible_multiselects = $(input_select + ' select[multiple]:not(.multiselect)');
    $eligible_multiselects.each(function(index, element) {
      var $element = $(element);
      var $options = $element.find('option');

      // Ignore if select doesn't have enough options to warrant additional actions
      if ($options.length < 10) {
        return;
      }

      // Insert Select All btn above select
      var $label = $element.closest(input_select).find('label:first');
      var $actions_wrap = $('<div />', {
        class: 'multiselect-action_wrap'
      });
      var $select_all_action = $('<div/>', {
        class: 'js-multiselect-action-select_all multiselect-action',
        html: $('<a/>', {
          href: '#',
          html: 'Select All'
        })
      });
      var $deselect_all_action = $('<div/>', {
        class: 'js-multiselect-action-deselect_all multiselect-action-deselect_all multiselect-action',
        html: $('<a/>', {
          href: '#',
          html: 'Deselect All'
        })
      });
      var $invert_selection_action = $('<div/>', {
        class: 'js-multiselect-action-invert_selection multiselect-action-invert_selection multiselect-action',
        html: $('<a/>', {
          href: '#',
          html: 'Invert Selection'
        })
      });

      // Add actions to wraper
      $select_all_action.appendTo($actions_wrap);
      $deselect_all_action.appendTo($actions_wrap);
      $invert_selection_action.appendTo($actions_wrap);

      // Add wrapper below form label
      $actions_wrap.insertAfter($label);
    });

    // Handle click on Select All btn
    $('#js-main-content').on('click', '.js-multiselect-action-select_all', function(e) {
      setAllOptionsSelected(e, this, true);
    });

    // Handle click on Deselect All btn
    $('#js-main-content').on('click', '.js-multiselect-action-deselect_all', function(e) {
      setAllOptionsSelected(e, this, false);
    });

    // Handle click on Invert Selection btn
    $('#js-main-content').on('click', '.js-multiselect-action-invert_selection', function(e) {
      setAllOptionsSelected(e, this, 'swap');
    });

    function setAllOptionsSelected(e, select, state) {
      e.preventDefault();
      var $select = $(select).closest(input_select).find('select');
      // If requested, swap the selected state of all multiselect options
      if (state === 'swap') {
        $select.find('option').each(function(index, element) {
          $(element).prop('selected', !$(element).prop('selected'));
        });
      } else {
        // Otherwise set selection state per provided state boolean
        $select.find('option').prop('selected', state);
      }
      $select.trigger('chosen:updated');
    }
  }

};
