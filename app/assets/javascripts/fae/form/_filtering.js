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

    // init only on pages with filering, sorting or paging
    if (this.$filter_form.length || this.$pagination.length || $('.js-sort-column').length) {
      this.applyCookies();
      var has_hash_on_load = window.location.hash.length > 2;
      this.fry = new Fryr(this._refresh_table, {}, has_hash_on_load);
      this.setFilterDropDowns();

      this.filterFormListeners();
      this.paginationListeners();
      this.sortingSetup();
    }
  },

  _refresh_table: function() {
    // hardcode _this because this === Fryr object
    var _this = Fae.form.filtering;
    var post_url = _this.$filter_form.attr('action');

    $.post(post_url, this.params, function(data){
      _this.$filter_form.next('table').replaceWith( $(data).find('table').first() );
      _this.$pagination.html( $(data).find('.pagination').first().html() );

      Fae.tables.columnSorting();
      Fae.tables.rowSorting();
      Fae.tables.sortColumnsFromCookies();
      Fae.navigation.lockFooter();
    });
  },

  filterFormListeners: function() {
    var _this = this;

    this.$filter_form
      .on('submit', function(ev) {
        ev.preventDefault();
        _this.updateFryrAndResetPaging('search', $('#filter_search').val());
      })
      // Reset filter button
      .on('click', '.js-reset-btn', function(ev) {
        var $this = $(this);
        ev.preventDefault();

        _this.fry.merge({ page: '' }, true);
        $this.closest('form').find('select').val('').trigger('chosen:updated');
        $this.hide();
      })

      .on('click', '.table-filter-keyword-wrapper i', function() {
        _this.updateFryrAndResetPaging('search', $('#filter_search').val());
      })

      .on('change', 'select', function() {
        // Update hash when filter dropdowns changed
        var key = $(this).attr('id').split('filter_')[1];
        var value = $(this).val();

        _this.updateFryrAndResetPaging(key, value);

        $('.js-reset-btn').show();
      });
  },

  setFilterDropDowns: function() {
    var cookie_name = this.$filter_form.attr('data-cookie-key');
    Cookies.set(cookie_name, this.fry.params);

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

  updateFryrAndResetPaging: function(key, value) {
    var values_obj = { page: '' };
    values_obj[key] = value;
    this.fry.merge(values_obj);
  },

  paginationListeners: function() {
    var _this = this;
    $('.pagination').on('click', 'a', function(ev) {
      ev.preventDefault();
      _this.fry.merge({ page: $(this).data('page') });
    })
  },

  sortingSetup: function() {
    this._add_sorting_classes();
    this._add_sorting_listeners();
  },

  _add_sorting_classes: function() {
    var sort_by = this.fry.params.sort_by;
    var sort_direction = this.fry.params.sort_direction;
    if (!sort_direction) {
      sort_direction = 'asc';
    }

    $('th[data-sort]')
      .wrapInner('<div class="th-sortable-title"></div>')
      .filter('[data-sort="'+sort_by+'"]').addClass('-'+sort_direction);
  },

  _add_sorting_listeners: function() {
    var _this = this;

    $('th[data-sort]').on('click', function() {
      var $this = $(this);
      var new_direction = 'asc';

      if ($this.hasClass('-asc')) {
        new_direction = 'desc';
        $this.addClass('-desc').removeClass('-asc');
      } else {
        $this.addClass('-asc').removeClass('-desc');
      }

      _this.fry.merge({
        sort_by: $this.data('sort'),
        sort_direction: new_direction,
        page: ''
      });
    });
  },

  /**
   * If cookies are available, load them into the hash
   */
  applyCookies: function() {
    var cookie_key = $('.js-filter-form').attr('data-cookie-key');

    if (cookie_key) {
      var cookie = Cookies.getJSON(cookie_key);

      if (!$.isEmptyObject(cookie)) {
        var keys = Object.keys(cookie)
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
  },

};
