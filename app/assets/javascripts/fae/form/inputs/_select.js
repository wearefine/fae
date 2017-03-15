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
   * Adds functionality for Select All and Deselect All multiselect options
   */
  multiselectChosenActions: function() {
    var query_input_select = '.input.select';
    var query_eligible_multiselects = query_input_select + ' select[multiple]:not(.multiselect)';
    var select_all_value = 'multiselect_action-select_all';

    var $eligible_multiselects = $(query_eligible_multiselects);
    $eligible_multiselects.each(function(index, element) {
      var $element = $(element);
      var $options = $element.find('option');

      // Ignore if select doesn't have enough options to warrant additional actions
      if ($options.length < 2) {
        return;
      }

      // Insert Select All btn above select
      var $label = $element.closest(query_input_select).find('label:first');
      var $deselect_all_action = $('<div/>', {
        class: 'js-multiselect-action-deselect_all multiselect-action-deselect_all multiselect-action',
        html: $('<a/>', {
          href: '#',
          tabindex: '-1',
          html: 'Deselect&nbsp;All'
        })
      });

      // Add actions to wraper
      $deselect_all_action.appendTo($label);

      // Add special "Select All" option and notify Chosen of new option
      addSelectAllOption($element)

      // Mark label wrapper as having multiselect actions for styling
      $label.addClass('has-multiselect-actions');
    });

    // Watch select for changes and add, remove, or carry out Select All option as needed
    $('#js-main-content').on('change', query_eligible_multiselects, function(e) {
      var $element = $(e.currentTarget);

      // Fizzle on empty values
      if (!$element.val()) { return; }

      // Intercept selections of the Select All option and select all other options.
      var requesting_select_all = $element.val().indexOf(select_all_value) != -1;
      if (requesting_select_all) {
        setAllOptionsSelected($element, true);
      }
    });

    // Handle click on Deselect All btn
    $('#js-main-content').on('click', '.js-multiselect-action-deselect_all', function(e) {
      e.preventDefault();
      setAllOptionsSelected(this, false);
    });

    // Add special "Select All" option
    function addSelectAllOption($element) {
      var $select_all_option = $('<option />', {
        value: select_all_value,
        text: 'Select All'
      });
      $select_all_option.prependTo($element);
      $element.trigger('chosen:updated');
    }

    // Remove "Select All" option
    function ignoreSelectAllOption($element) {
      $element.find('option[value="' + select_all_value + '"]').prop('selected', false);
    }

    // Mark all options as selected or not
    function setAllOptionsSelected(select, state) {
      var $select = $(select).closest(query_input_select).find('select');
      // Set selection state per provided state boolean
      $select.find('option').prop('selected', state);
      // Always ignore magic Select All btn
      $select.find('option[value="' + select_all_value + '"]').prop('selected', false);
      $select.trigger('chosen:updated');
    }
  }

};
