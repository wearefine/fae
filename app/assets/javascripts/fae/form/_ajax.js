/* global Fae, fae_chosen, fileinputer, FCH, Cookies */

/**
 * Fae AJAX
 * @namespace form.ajax
 * @memberof form
 */
Fae.form.ajax = {

  init: function() {
    this.$addedit_form = $('.js-addedit-form, .js-index-addedit-form');
    this.$filter_form = $('.js-filter-form');
    this.$nested_form = $('.nested-form');

    this.addEditLinks();
    this.addEditSubmission();

    this.addCancelLinks();

    this.imageDeleteLinks();
    this.htmlListeners();

    this.deleteNoForm();
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

      // Bind validation to nested form fields added by AJAX
      Fae.form.validator.bindValidationEvents(this.$nested_form);

      // Reinitialize form elements
      Fae.form.dates.initDatepicker();
      Fae.form.dates.initDateRangePicker();
      Fae.form.color.initColorpicker();
      Fae.form.slugger.addListener();
      Fae.form.validator.length_counter.init();
      Fae.form.text.initMarkdown();
      Fae.form.checkbox.setCheckboxAsActive();
      Fae.form.select.init();

      // validate nested form fields on submit
      Fae.form.validator.formValidate(this.$nested_form);

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

        // if its the new or old remotipart, return the html
        var $html = $(data).length === 1 ? $(data) : $(data)[3];

        // if it returns data inside textarea, strip that out
        if ( $($html).is('textarea') ) {
          $html = $( $($html).val() );
        }

        if ($html) {
          if($html.hasClass('js-addedit-form') || $html.hasClass( 'js-index-addedit-form' )) {
            // we're returning the table, replace everything
            _this._addEditReplaceAndReinit($this, $html.html(), $target);
          } else if ($html.hasClass('nested-form')) {

            // we're returning the form due to an error, just replace the form
            $this.find('.nested-form' ).replaceWith($html);
            $this.find('.select select').fae_chosen();
            $this.find('.input.file').fileinputer();

            Fae.form.dates.initDatepicker();
            Fae.form.dates.initDateRangePicker();
            Fae.form.color.initColorpicker();
            Fae.form.validator.length_counter.init();
            Fae.form.checkbox.setCheckboxAsActive();
            Fae.form.text.initMarkdown();

            FCH.smoothScroll($this.find('.js-addedit-form-wrapper'), 500, 100, 120);
          }
        }

        if (_this.$filter_form.length) {
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
   * Attach filter listeners
   */
  filterSubmission: function() {
    var _this = this;

    _this.$filter_form
      .on('submit', function() {
        $('.js-reset-btn').show();
      })

      // On filter change, update table data
      .on('ajax:success', function(evt, data, status, xhr){
        $(this).next('table').replaceWith( $(data).find('table').first() );
        $('.pagination').replaceWith( $(data).find('.pagination').first() );

        Fae.tables.columnSorting();
        Fae.tables.rowSorting();
        Fae.tables.sortColumnsFromCookies();
        Fae.navigation.lockFooter();
      })

      // Reset filter button
      .on('click', '.js-reset-btn', function(ev) {
        ev.preventDefault();

        var $form = $(this).closest('form');

        $form.get(0).reset();
        $form.find('select').val('').trigger('chosen:updated');
        // reset hashies
        window.location.hash = '';

        // Spoof form submission
        $form.submit();

        $(this).hide();
      })

      .on('click', '.table-filter-keyword-wrapper i', function() {
        _this.$filter_form.submit();
      })

      .on('change', 'select', function() {
        _this.$filter_form.submit();
        // Update hash when filter dropdowns changed
        var key = $(this).attr('id').split('filter_')[1];
        var value = $(this).val();
        _this.fry.update(key, value);
      });
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
   * Attaching click handlers to #js-main-content to allow ajax replacement
   * @todo Clean this up, moving listeners into their respective component classes (select, checkbox, etc.)
   */
  htmlListeners: function() {
    $('#js-main-content, .login-form > form')

      /**
       * For the delete button on file input
       */
      .on('click', '.js-file-clear', function(e) {
        e.preventDefault();
        var $parent = $(this).parent();
        $parent.next().show();
        $parent.hide();
      })

      /**
       * For the yes/no slider
       */
      .on('click', '.slider-wrapper', function(e){
        e.preventDefault();
        $(this).toggleClass('slider-yes-selected');
      })

      /**
       * The settings menu for tables and checkboxes
       */
      .on('click', '.boolean label, .js-checkbox-wrapper label', function(e){
        var $this = $(this);

        if(!$this.hasClass('disabled') && !$this.hasClass('readonly')) {
          $this.toggleClass('active');
        }
      })

      /**
       * Stop event bubbling and running the above toggleClass twice
       */
      .on('click', '.boolean :checkbox, .js-checkbox-wrapper :checkbox', function(e){
        e.stopPropagation();
      })

      /**
       * Support for a focus state on radio collections
       */
      .on('focus blur', '.radio_collection :radio', function(e) {
        $(this)
          .closest('.input.radio_collection')
          .toggleClass('focused', $(this).has(':focus'));
      })

      /**
       * Support for a focus state on checkboxes
       */
      .on('focus blur', '.boolean :checkbox, .js-checkbox-wrapper :checkbox', function(e) {
        $(this)
          .closest('label.boolean, span.checkbox')
          .toggleClass('focused', $(this).has(':focus'));
      })

      /**
       * Support spacebar toggling for checkboxes
       */
      .on('keydown', '.boolean, .js-checkbox-wrapper :checkbox', function(e) {
        if (e.which === 32) {
          e.preventDefault();
          $(':checkbox:focus')
            .closest('label')
            .trigger('click');
        }
      })

      /**
       * Support for shift+tab off of ms-list element.
       * By default, $.multiSelect() plugin captures shift+tab and disgards it
       * @todo This entire method feels very brittle. Possible alternative:
       * - Create an index of all focusable form elements on page load / DOM mutation
       * - Use this index to navigate upwards from .ms-list element
      */
      .on('keydown', '.ms-list', function(e) {
        if (e.which === 9 && e.shiftKey) {
          e.preventDefault();

          // Sniff out the previous focusable element
          var $prevFocusable = $(this)
            .closest('.input')
            .prevAll('.input:not(.hidden):first') // Ugh X(
            .find('input[type!=hidden][type!=file], select, button, textarea') // Yuck :(
            .first();

          // Trigger focus
          $prevFocusable.focus();

          // Check for select instance and further trigger focus via Chosen API
          if ($prevFocusable.is('select')) {
            $prevFocusable.trigger('chosen:activate');
          }
        }
      });
  }

};
