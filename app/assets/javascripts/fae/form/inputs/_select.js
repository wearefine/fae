/* global Fae, multiSelect */

'use strict';

Fae.form.select = {
  init: function() {
    var availableItemsStr = " Available Items";
    var addedItemsStr = " Added Items";

    $("select").each(function(index, elm){
      var $select = $(this);
      if($select.hasClass("multiselect")) {
        $select.multiSelect({
          selectableHeader: "<div class='custom-header'></div>",
          selectionHeader: "<div class='custom-header'></div>"
        });
        var selectableCount = $select.next('.ms-container').find('.ms-selectable li').not('.ms-selected').length
        var selectedCount = $select.next('.ms-container').find('.ms-selection .ms-selected').length;
        $('.ms-selectable .custom-header').text(selectableCount + availableItemsStr);
        $('.ms-selection .custom-header').text(selectedCount + addedItemsStr);
      } else {
        $select.fae_chosen();
      }
    });

    var $selectable = $('.ms-selectable .custom-header');
    var $selection = $('.ms-selection .custom-header');

    $('.ms-selectable li').on('click', function(){
      $selectable.text(parseInt($selectable.text()) -1 + availableItemsStr);
      $selection.text(parseInt($selection.text()) +1 + addedItemsStr);
    });

    $('.ms-selection li').on('click', function(){
      $selectable.text(parseInt($selectable.text()) + 1 + availableItemsStr);
      $selection.text(parseInt($selection.text()) -1 + addedItemsStr);
    })
  },
};
