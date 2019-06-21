/* global Fae, fae_chosen, fileinputer, FCH, Cookies */

/**
 * Fae Filtering, Sorting and Paging
 * @namespace form.filtering
 * @memberof form
 */
Fae.form.filtering = {

  init: function() {
    this.$filter_form = $('.js-filter-form');
    this.$pagination = $('.pagination');
    this.has_hash_on_load_and_cookie = false;

    // init only on pages with filering, sorting or paging
    if (this.$filter_form.length || this.$pagination.length || $('.js-sort-column').length) {
      this.applyCookies();
      var window_hash = window.location.hash;
      var has_hash_on_load = window_hash.length > 2;
      this.fry = new Fryr(this._refreshTable, {}, has_hash_on_load);

      // this.fry.params needs to be set to the "deep link" passed params
      if(has_hash_on_load) {
        this.fry.parse(window_hash);
      }

      this.setFilterDropDowns();
      this.setTextInputs();
      this.filterFormListeners();
      this.paginationListeners();
      this.sortingSetup();
    }
  },

  /**
   * Fryr callback, POSTs to Fae's endpoint and updates the view
   */
  _refreshTable: function() {
    // hardcode _this because this === Fryr object
    var _this = Fae.form.filtering;

    if (_this.$filter_form.length) {
      post_url = _this.$filter_form.attr('action');
      $current_table = _this.$filter_form.next('table');
    } else {
      post_url = _this.$pagination.data('filter-path');
      $current_table = _this.$pagination.prevAll(":visible:first");
    }

    var $results_table = ($(".js-results-table").length) ? $(".js-results-table").first() : $current_table;

    $results_table.addClass('loading-fade');

    $.post(post_url, this.params, function(data){
      var $data = $(data);
      var $table_from_data = $data.find('table').first();

      // replace table
      $results_table.replaceWith($table_from_data);

      // replace sticky header
      $('.sticky-table-header thead').html($table_from_data.find('thead').html());
      // replace pagination
      _this.$pagination.html($data.find('.pagination').first().html());

      // reinit a few things on the fresh table
      Fae.tables.columnSorting();
      Fae.tables.rowSorting();
      Fae.navigation.lockFooter();

      _this.sortingSetup();

      // dont set the cookie if it's a "deep link" and they have an existing cookie - leave that intact with their old saved filter
      if (!_this.has_hash_on_load_and_cookie) {
        _this.setCookie();
      }
    });
  },


  /**
   * Adds listeners to the filter forms
   */
  filterFormListeners: function() {
    var _this = this;

    this.$filter_form
      // update search param when form submits
      .on('submit', function(ev) {
        $('.js-reset-btn').show();
        _this.updateFryrAndResetPaging('search', $('#filter_search').val());
        return false;
      })

      // update search param when search btn is clicked
      .on('click', '.table-filter-keyword-wrapper i', function() {
        _this.updateFryrAndResetPaging('search', $('#filter_search').val());
      })

      // reset filter button
      .on('click', '.js-reset-btn', function(ev) {
        var $this = $(this);
        ev.preventDefault();

        // reset params and form selects
        _this.fry.merge({ page: '' }, true);
        $('#filter_search').val('');
        $this.closest('form').find('select').val('').trigger('chosen:updated');
        $this.hide();
      })

      // update hash when filter dropdowns changed
      .on('change', 'select', function() {
        // get key and value from select
        var key = $(this).attr('id').split('filter_')[1];
        var value = $(this).val();

        _this.updateFryrAndResetPaging(key, value);

        $('.js-reset-btn').show();
      })

      // update hash when date inputs changed
      .on('change', '.datepicker input', function() {
        var key = $(this).attr('id').split('filter_')[1];
        var value = $(this).val();
        timer = setTimeout(function() {
          _this.updateFryrAndResetPaging(key, value);
          $('.js-reset-btn').show();
        }, 500);
      });
  },

  /**
   * Sets filter dropdowns on page load based on Fryr params
   */
  setFilterDropDowns: function() {
    // Exit early if this.fry.params is blank
    if ($.isEmptyObject(this.fry.params)) {
      return;
    }

    // Loop through all available this.fry.params to find the select menu and the proper option
    $.each(this.fry.params, function(key, value) {
      var $select = $('.js-filter-form .table-filter-group #filter_' + key);

      if($select.length) {
        var $option = $select.find('option[value="' + value + '"]');

        // Ensure we find the option and that it isn't already chosen
        if($option.length && $option.prop('selected') !== 'selected') {
          $option.prop('selected', 'selected');
          $select.trigger('chosen:updated');
        }
      }
    });

    $('.js-reset-btn').show();
  },

  /**
   * Sets filter dropdowns on page load based on Fryr params
   */
  setTextInputs: function() {
    // Exit early if this.fry.params is blank
    if ($.isEmptyObject(this.fry.params)) {
      return;
    }

    // Loop through all available this.fry.params to find the select menu and the proper option
    $.each(this.fry.params, function(key, value) {
      var $input = $('.js-filter-form .table-filter-group.text-input #filter_' + key);

      if($input.length) {
        $input.val(decodeURIComponent(value));
      }
    });

    $('.js-reset-btn').show();
  },

  /**
   * Updates a Fryr param while reseting paging
   * Use for most cases of pushing a single params to Fryr, as paging will always reset in those cases
   * @param {string} key - The Fryr param key to be changed
   * @param {string} value - The value to be changed to
   */
  updateFryrAndResetPaging: function(key, value) {
    var values_obj = { page: '' };
    values_obj[key] = value;
    this.fry.merge(values_obj);
  },

  /**
   * Adds listeners to pagination
   */
  paginationListeners: function() {
    var _this = this;
    // update params when pagination link clicked
    $('.pagination').on('click', 'a', function(ev) {
      ev.preventDefault();
      _this.fry.merge({ page: $(this).data('page') });
    })
  },

  /**
   * Wrapper method to setup HTML and listeners to support sorting
   * Called on load and this._refreshTable()
   */
  sortingSetup: function() {
    this._addSortingClasses();
    this._addSortingListeners();
  },

  /**
   * Updates sortable table headers
   */
  _addSortingClasses: function() {
    // get sort_by and sort_direction from Fryr
    var sort_by = this.fry.params.sort_by;
    var sort_direction = this.fry.params.sort_direction;
    if (!sort_direction) {
      sort_direction = 'asc';
    }

    var $sortable_th = $('th[data-sort]');
    // add sort_direction class to current sorted column
    $sortable_th.filter('[data-sort="'+sort_by+'"]').addClass('-'+sort_direction);
    // add .th-sortable-title to support styling
    $sortable_th.not(':has(.th-sortable-title)').wrapInner('<div class="th-sortable-title"></div>');
  },

  /**
   * Adds listeners to the sortable table headers
   */
  _addSortingListeners: function() {
    var _this = this;

    // Fizzle if listeneres have already been attached
    if (this._are_sorting_listeners_setup === true) { return; }

    $('body').on('click', 'th[data-sort]', function() {
      var $this = $(this);
      var new_direction = 'asc';

      // update sort_direction class
      if ($this.hasClass('-asc')) {
        new_direction = 'desc';
        $this.addClass('-desc').removeClass('-asc');
      } else {
        $this.addClass('-asc').removeClass('-desc');
      }

      // update Fryr
      _this.fry.merge({
        sort_by: $this.data('sort'),
        sort_direction: new_direction,
        page: ''
      });
    });

    // To ensure listeners are only attached once
    this._are_sorting_listeners_setup = true;
  },

  /**
   * Sets the filter form's cookie to the Fryr params
   */
  setCookie: function() {
    var cookie_name = this.$filter_form.attr('data-cookie-key');
    Cookies.set(cookie_name, this.fry.params);
  },

  /**
   * If cookies are available, load them into the hash
   */
  applyCookies: function() {
    var cookie_key = $('.js-filter-form').attr('data-cookie-key');

    if (cookie_key) {
      var cookie = Cookies.getJSON(cookie_key);

      if (!$.isEmptyObject(cookie)) {

        // exit now if it's a "deep link" so the passed params get used instead of saved cookie params
        if (window.location.hash.length > 2) {
          this.has_hash_on_load_and_cookie = true;
          return false;
        }

        var keys = Object.keys(cookie);
        var hash = '?';

        for(var i = 0; i < keys.length; i++) {
          if (hash !== '?') {
            hash += '&';
          }
          hash += keys[i] + '=' + cookie[keys[i]];
        }

        if (hash !== '?') {
          window.location.hash = hash;
        }
      }
    }
  }

};
