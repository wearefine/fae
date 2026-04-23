/* global Fae, FCH */

/**
 * Fae form ranked select
 * @namespace form.rankedSelect
 * @memberof form
 */
Fae.form.rankedSelect = {

  init: function() {
    this.initializeChosenSelects();
    this.bindRankedSelects();
    this.initializeSortables();
  },

  /**
   * Initialize Chosen on any ranked select elements that don't already have it
   */
  initializeChosenSelects: function() {
    $('.js-ranked-select').each(function() {
      var $select = $(this);
      // Check if Chosen is already initialized (look for the chosen container)
      var chosenId = $select.attr('id') + '_chosen';
      if ($('#' + chosenId).length === 0 && typeof $.fn.fae_chosen !== 'undefined') {
        $select.fae_chosen();
      }
    });
  },

  /**
   * Initialize sortable on all ranking tables
   */
  initializeSortables: function() {
    var _this = this;
    $('.js-ranking-table').each(function() {
      _this.reinitializeSortable($(this));
    });
  },

  /**
   * Bind change events on ranked selects to update their associated ranking tables
   */
  bindRankedSelects: function() {
    var _this = this;
    
    // Handle multiSelect (two-pane select) changes
    $('.js-ranked-select').each(function() {
      var $select = $(this);
      var rankingTableId = $select.data('ranking-table');
      
      if (!rankingTableId) return;
      
      var $rankingTable = $('#' + rankingTableId);
      if (!$rankingTable.length) return;
      
      // Store the previous selection to detect adds/removes
      $select.data('previous-selection', ($select.val() || []).slice());
      
      // Watch for actual value changes on the hidden select
      $select.off('change.rankedSelect').on('change.rankedSelect', function() {
        _this.handleSelectionChange($select, $rankingTable);
      });
      
      // For multiSelect, also watch the afterSelect and afterDeselect callbacks
      // We'll use a MutationObserver to watch for changes to the select options
      _this.observeSelectChanges($select, $rankingTable);
    });
  },

  /**
   * Use MutationObserver to watch for changes to select options (selected state)
   */
  observeSelectChanges: function($select, $rankingTable) {
    var _this = this;
    var select = $select[0];
    
    if (!select) return;
    
    // Check if we already have an observer
    if ($select.data('ranking-observer')) {
      return;
    }
    
    var observer = new MutationObserver(function(mutations) {
      _this.handleSelectionChange($select, $rankingTable);
    });
    
    // Observe changes to the select's children (options being selected/deselected)
    observer.observe(select, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['selected']
    });
    
    $select.data('ranking-observer', observer);
  },

  /**
   * Handle selection changes - detect what was added/removed and update accordingly
   */
  handleSelectionChange: function($select, $rankingTable) {
    var _this = this;
    var currentSelection = ($select.val() || []).map(function(id) { return String(id); });
    var previousSelection = ($select.data('previous-selection') || []).map(function(id) { return String(id); });
    
    // Find added and removed items
    var added = currentSelection.filter(function(id) { return previousSelection.indexOf(id) === -1; });
    var removed = previousSelection.filter(function(id) { return currentSelection.indexOf(id) === -1; });
    
    // Update previous selection for next time
    $select.data('previous-selection', currentSelection.slice());
    
    // Process removals
    removed.forEach(function(associatedId) {
      _this.removeItem($select, $rankingTable, associatedId);
    });
    
    // Process additions
    added.forEach(function(associatedId) {
      _this.addItem($select, $rankingTable, associatedId);
    });
  },
  
  /**
   * Update the visibility of the empty row placeholder
   */
  updateEmptyRowVisibility: function($rankingTable) {
    var $tbody = $rankingTable.find('tbody');
    var $emptyRow = $tbody.find('.js-ranking-empty-row');
    if ($tbody.find('.js-ranking-row').length > 0) {
      $emptyRow.hide();
    } else {
      $emptyRow.show();
    }
  },

  /**
   * Add an item - create join record via AJAX and add to table
   */
  addItem: function($select, $rankingTable, associatedId) {
    var _this = this;
    var collection = this.getCollection($rankingTable);
    var item = this.findInCollection(collection, associatedId);
    
    if (!item) return;
    
    // Get AJAX params from data attributes
    var parentModel = $select.data('parent-model');
    var parentId = $select.data('parent-id');
    var joinModel = $select.data('join-model');
    var associatedModel = $select.data('associated-model');
    
    // Create join record via AJAX
    $.ajax({
      url: Fae.path + '/ranked_item',
      type: 'POST',
      data: {
        action_type: 'add',
        parent_model: parentModel,
        parent_id: parentId,
        join_model: joinModel,
        associated_model: associatedModel,
        associated_id: associatedId
      },
      dataType: 'json',
      success: function(response) {
        if (response.success) {
          // Add row to table with the real join record ID
          _this.addRowToTable($rankingTable.find('tbody'), item, response.join_record_id, associatedId);
          _this.reinitializeSortable($rankingTable);
          _this.updateEmptyRowVisibility($rankingTable);
        }
      },
      error: function(xhr) {
        console.warn('Failed to create ranked item:', xhr.responseText);
        // Still add to table visually, will be created on form save
        _this.addRowToTable($rankingTable.find('tbody'), item, null, associatedId);
        _this.reinitializeSortable($rankingTable);
        _this.updateEmptyRowVisibility($rankingTable);
      }
    });
  },

  /**
   * Remove an item - destroy join record via AJAX and remove from table
   */
  removeItem: function($select, $rankingTable, associatedId) {
    var _this = this;
    var $tbody = $rankingTable.find('tbody');
    
    // Find and remove the row
    $tbody.find('.js-ranking-row').each(function() {
      var rowAssociatedId = String($(this).data('associated-id') || $(this).data('id'));
      if (rowAssociatedId === associatedId) {
        $(this).remove();
      }
    });
    
    // Update empty row visibility after removing
    _this.updateEmptyRowVisibility($rankingTable);
    
    // Get AJAX params from data attributes
    var parentModel = $select.data('parent-model');
    var parentId = $select.data('parent-id');
    var joinModel = $select.data('join-model');
    var associatedModel = $select.data('associated-model');
    
    // Delete join record via AJAX
    $.ajax({
      url: Fae.path + '/ranked_item',
      type: 'POST',
      data: {
        action_type: 'remove',
        parent_model: parentModel,
        parent_id: parentId,
        join_model: joinModel,
        associated_model: associatedModel,
        associated_id: associatedId
      },
      dataType: 'json',
      error: function(xhr) {
        console.warn('Failed to remove ranked item:', xhr.responseText);
      }
    });
  },

  /**
   * Get collection data from the embedded JSON
   */
  getCollection: function($rankingTable) {
    var $collectionData = $rankingTable.find('.js-ranking-collection');
    if ($collectionData.length) {
      try {
        return JSON.parse($collectionData.html());
      } catch (e) {
        console.warn('Could not parse ranking collection data');
        return [];
      }
    }
    return [];
  },

  /**
   * Find an item in the collection by ID
   */
  findInCollection: function(collection, id) {
    for (var i = 0; i < collection.length; i++) {
      if (String(collection[i].id) === String(id)) {
        return collection[i];
      }
    }
    return null;
  },

  /**
   * Add a new row to the ranking table
   */
  addRowToTable: function($tbody, item, joinRecordId, associatedId) {
    console.log('Adding row to table for item:', item);
    var $rankingTable = $tbody.closest('.js-ranking-table');
    var joinModel = $rankingTable.data('join-model');
    var showPreviewImage = $rankingTable.data('preview-image');
    // Convert CamelCase to snake_case and pluralize (e.g., BeerAroma -> beer_aromas)
    var snakeCaseModel = joinModel.replace(/([A-Z])/g, function(match, p1, offset) {
      return (offset > 0 ? '_' : '') + p1.toLowerCase();
    });
    var pluralModel = snakeCaseModel + 's';
    var rowId = joinRecordId ? pluralModel + '_' + joinRecordId : null;
    var dataId = joinRecordId || associatedId;
    var previewCell = '';

    if (showPreviewImage) {
      console.log('Item preview image URL:', item.preview_image_url);
      previewCell = '<td>';
      if (item.preview_image_url) {
        previewCell += '<img src="' + this.escapeHtml(item.preview_image_url) + '" />';
      }
      previewCell += '</td>';
    }
    
    var $row = $('<tr class="js-ranking-row" data-id="' + dataId + '" data-associated-id="' + associatedId + '"' + 
      (rowId ? ' id="' + rowId + '"' : '') + '>' +
      '<td class="sortable-handle"><i class="icon-sort"></i></td>' +
      '<td>' + this.escapeHtml(item.name) + '</td>' +
      previewCell +
      '</tr>');
    
    // Insert before empty row if it exists, otherwise append
    var $emptyRow = $tbody.find('.js-ranking-empty-row');
    if ($emptyRow.length) {
      $emptyRow.before($row);
    } else {
      $tbody.append($row);
    }
  },

  /**
   * Escape HTML to prevent XSS
   */
  escapeHtml: function(str) {
    if (!str) return '';
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  /**
   * Reinitialize jQuery UI sortable on the table
   */
  reinitializeSortable: function($rankingTable) {
    var $table = $rankingTable.find('table.js-sort-row');
    var $tbody = $table.find('tbody');
    
    // Destroy existing sortable if it exists
    if ($tbody.hasClass('ui-sortable')) {
      $tbody.sortable('destroy');
    }
    
    // Re-initialize sortable using Fae.tables.rowSorting logic
    // This sends AJAX to /sort/{object} which updates positions
    if ($tbody.find('tr.js-ranking-row').length > 0 && typeof $.fn.sortable !== 'undefined') {
      $tbody.sortable({
        handle: '.sortable-handle',
        items: 'tr.js-ranking-row',
        opacity: 0.8,
        helper: function(e, $tr) {
          var $originals = $tr.children();
          var $helper = $tr.clone();
          var $ths = $tr.closest('table').find('th');
          
          $helper.children().each(function(index) {
            $(this).width($originals.eq(index).width());
            $ths.eq(index).width($ths.eq(index).width());
          });
          
          return $helper;
        },
        stop: function(e, ui) {
          $(ui.item).closest('table').find('th').css('width', '');
        },
        update: function() {
          var $this = $(this);
          var serial = $this.sortable('serialize');
          var object = serial.substr(0, serial.indexOf('['));
          
          if (object && serial) {
            $.ajax({
              url: Fae.path + '/sort/' + object,
              type: 'post',
              data: serial,
              dataType: 'script'
            });
          }
        }
      });
    }
  },

  /**
   * Find the select element associated with a ranking table
   */
  findSelectForTable: function($rankingTable) {
    var tableId = $rankingTable.attr('id');
    return $('[data-ranking-table="' + tableId + '"]');
  }
};
