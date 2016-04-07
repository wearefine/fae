/* global Fae, fae_chosen, fileinputer, FCH, Cookies */

'use strict';

/**
 * Fae AJAX
 * @namespace form.ajax
 * @memberof form
 */
Fae.form.ajax = {

  init: function() {
    this.$addedit_form = $('.js-addedit-form, .js-index-addedit-form');
    this.$filter_form = $('.js-filter-form');

    this.addEditLinks();
    this.addEditSubmission();

    this.addCancelLinks();

    this.imageDeleteLinks();
    this.htmlListeners();
    this.applyCookies();

    this.deleteNoForm();

    // Re-applied once AJAX form is loaded in
    if (this.$filter_form.length) {
      this.filterSelect();
      this.filterSubmission();
    }
  },

  /**
   * Click event listener for add and edit links applied to both index and nested forms
   */
  addEditLinks: function() {
    var _this = this;

    this.$addedit_form.on('click', '.js-add-link, .js-edit-link', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $parent = $this.hasClass('js-index-add-link') ? $('.js-addedit-form') : $this.closest('.js-addedit-form');

      // scroll to the last column of the tbody, where the form will start
      FCH.smoothScroll($parent.find('tbody tr:last-child'), 500, 450, -20);

      _this._addEditActions($this.attr('href'), $parent.find('.js-addedit-form-wrapper'));
    });
  },

  /**
   * Once add or edit is clicked, load remote data, add it to the DOM and initialize listeners on the new create form
   * @protected
   * @param {String} remote_url - Remote page to load form from
   * @param {jQuery} $wrapper - Whole form container
   * @see addEditLinks
   */
  _addEditActions: function(remote_url, $wrapper) {

    $.get(remote_url, function(data){
      // check to see if the content is hidden and slide it down if it is.
      if ($wrapper.is(':hidden')) {
        // replace the content of the form area and initiate the chosen and fileinputer
        $wrapper.html(data).find('.select select').fae_chosen({ width: '300px' });
        $wrapper.find('.input.file').fileinputer();
        $wrapper.slideDown();

      } else {
        // if it is visible, replace its content by retaining height
        $wrapper.height($wrapper.height());

        // replace the content of the form area and then remove that height and then chosen and then fileinputer
        $wrapper.html(data).css('height', '').find('.select select').fae_chosen();
        $wrapper.find('.input.file').fileinputer();
      }

      // Reinitialize form elements
      Fae.form.dates.initDatepicker();
      Fae.form.dates.initDateRangePicker();
      Fae.form.text.slugger();
      Fae.form.validator.length_counter.init();
      Fae.form.text.initMarkdown();
      Fae.form.checkbox.setCheckboxAsActive();

      $wrapper.find('.hint').hinter();
    });
  },

  /**
   * Click event listener for cancel links applied to both index and nested forms; clears form to prevent saving errors
   */
  addCancelLinks: function() {
    this.$addedit_form.on('click', '.js-cancel-nested', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $form_wrapper = $this.closest('.js-addedit-form-wrapper');

      if ($form_wrapper.length) {
        $form_wrapper.slideUp('normal', function(){
          $form_wrapper.empty();
        });
      }
    });
  },

  /**
   * Once form is submitted and receives a successful AJAX response, replace form data and initialize listeners on nested elements
   * @fires {@link navigation.fadeNotices}
   */
  addEditSubmission: function() {
    var _this = this;

    this.$addedit_form.on('ajax:success', function(evt, data, status, xhr){

      var $target = $(evt.target);

      // ignore calls not returning html
      if (data !== ' ' && $(data)[0]) {
        var $this = $(this);
        var $html = $(data);

        // remotipart returns data inside textarea, let's grab it from there
        if ($html.is('textarea')) {
          $html = $( $html.val() );
        }

        if ($html) {
          if($html.hasClass('js-addedit-form') || $html.hasClass( 'js-index-addedit-form' )) {
            // we're returning the table, replace everything
            _this._addEditReplaceAndReinit($this, $html.html(), $target);
          } else if ($html.hasClass('form_content-wrapper')) {

            // we're returning the form due to an error, just replace the form
            $this.find('.form_content-wrapper').replaceWith(data);
            $this.find('.select select').fae_chosen();
            $this.find('.input.file').fileinputer();

            FCH.smoothScroll($this.find('.js-addedit-form-wrapper'), 500, 100, 120);
          }
        }

        if (_this.$filter_form.length) {
          _this.filterSelect();
          _this.filterSubmission();
        }

        Fae.navigation.fadeNotices();

      } else if ($target.hasClass('js-asset-delete')) {
        // handle remove asset links on nested forms
        var $parent = $target.closest('.asset-actions');

        $parent.fadeOut(function(){
          $parent.next('.asset-inputs').fadeIn();
        });
      }

      Fae.navigation.lockFooter();
    });
  },

  /**
   * Replace AJAX'd form and add calls to all new HTML elements
   * @protected
   * @param $el {jQuery} - Object to be replaced
   * @param html {String} - New HTML
   * @param $target {jQuery} - Original form wrapper
   * @see addEditSubmission
   */
  _addEditReplaceAndReinit: function($el, html, $target) {
    var $form_wrapper = $el.find('.js-addedit-form-wrapper');

    // Private function replaces parent element with HTML and reinits select and sorting
    function regenerateHTML() {
      // .html() is not replacing it properly
      $el.get(0).innerHTML = html;
      $el.find('.select select').fae_chosen();
      Fae.tables.rowSorting();
      Fae.navigation.fadeNotices();

      if ($el.find('.js-content-header').length) {
        Fae.navigation.stickyHeaders(true);
      }
    }

    // if there's a form wrap, slide it up before replacing content
    if ($form_wrapper.length) {
      $form_wrapper.slideUp(regenerateHTML);

    } else {
      regenerateHTML();
    }

    if (!$target.hasClass('js-delete-link')) {
      FCH.smoothScroll($el.parent(), 500, 100, 120);
    }
  },

  /**
   * On filter change, update table data
   */
  filterSubmission: function() {
    var _this = this;

    _this.$filter_form
      .on('ajax:success', function(evt, data, status, xhr){
        $(this).next('table').replaceWith( $(data).find('table').first() );
        Fae.navigation.lockFooter();
      })

      .on('click', '.js-reset-btn', function(ev) {
        var $form = $(this).closest('form');

        $form.get(0).reset();
        $form.find('select').val('').trigger('chosen:updated');
        // reset hashies
        window.location.hash = '';
      })

      .on('change', 'select', function() {
        _this.$filter_form.submit();
      });
  },

  /**
   * If cookies are available, load them into the hash
   */
  applyCookies: function() {
    var cookie_key = $('.js-filter-form').attr('data-cookie-key');

    this.grind = new Grinder(this._setFilterDropdowns);

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

  /**
   * Update hash when filter dropdowns changed
   */
  filterSelect: function(){
    var _this = this;
    $('.js-filter-form .table-filter-group').on('change', function(){
      if ($('.js-filter-form').attr('data-cookie-key')) {
        var key = $(this).find('select').attr('id').split('filter_')[1];
        var value = $(this).find('option:selected').val();

        _this.grind.update(key, value, false, true);
      }
    });
  },

  /**
   * Check for cookie or hash and set dropdowns/ url accordingly (callback for Grinder)
   * @protected
   * @param {Object} params - hash params broken out from Grinder
   * @see applyCookies
   */
  _setFilterDropdowns: function(params) {
    var cookie_name = $('.js-filter-form').attr('data-cookie-key');
    Cookies.set(cookie_name, params);

    if (!$.isEmptyObject(params)) {
      $.each(params, function(k, v) {
        $('.js-filter-form .table-filter-group').each(function(){
          var $this = $(this);
          var key = $this.find('select').attr('id').split('filter_')[1];
          var value = $this.find('option:selected').val();

          if (k === key) {
            $this.find('option').each(function(){
              if ($this.val() === v) {
                $this.prop('selected', 'selected');
                $('#filter_' + key).trigger('chosen:updated');
              };
            });
          }
        });
      });

      $('.js-filter-form').submit();
    }
  },

  /**
   * Delete or replace file for non-AJAX'd fields
   */
  deleteNoForm: function() {
    $('.js-asset-delete').on('ajax:success', function(){
      var $this = $(this);
      if (!$this.closest('.js-addedit-form-wrapper').length) {
        // handle remove asset links
        var $parent = $this.closest('.asset-actions');

        $parent.fadeOut(function(){
          $parent.next('.asset-inputs').fadeIn();
        });
      }
    });
  },

  /**
   * Attach delete listener to images uploaded
   */
  imageDeleteLinks: function() {
    $('.imageDeleteLink').click(function(e) {
      e.preventDefault();
      var $this = $(this);

      if (confirm('Are you sure you want to delete this image?')) {
        $.post($this.attr('href'), 'html');
        $this.parent().next().show();
        $this.parent().hide();
      }
    });
  },

  /**
   * Attaching click handlers to #main_content to allow ajax replacement
   */
  htmlListeners: function() {
    $('#js-main-content')

      // for the yes/no slider
      .on('click', '.slider-wrapper', function(e){
        e.preventDefault();
        $(this).toggleClass('slider-yes-selected');
      })

      // The settings menu for tables and checkboxes
      .on('click', '.boolean label, .js-checkbox-wrapper label', function(e){
        $(this).toggleClass('active');
      })

      // stop the event bubbling and running the above toggleClass twice
      .on('click', '.boolean :checkbox, .js-checkbox-wrapper :checkbox', function(e){
        e.stopPropagation();
      });
  }

};
