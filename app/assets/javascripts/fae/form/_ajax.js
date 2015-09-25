/* global Fae */

'use strict';

Fae.form.ajax = {

  init: function() {
    this.$addedit_form = $('.js-addedit-form, .js-index-addedit-form');
    this.$filter_form = $('.js-filter-form');

    this.addEditLinks();
    this.addEditSubmission();

    this.imageDeleteLinks();
    this.htmlListeners();
    this.applyCookies();

    // Re-applied once AJAX form is loaded in
    this.deleteNoForm();
    if( this.$filter_form.length ) {
      this.filterSelect();
      this.filterSubmission();
    }
  },

  // Click event listener for add and edit links
  // Applies to both index and nested form
  addEditLinks: function() {
    var _this = this;

    this.$addedit_form.on('click', '.js-add-link, .js-edit-link', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $parent = $this.hasClass('js-index-add-link') ? $('.js-addedit-form') : $this.closest('.js-addedit-form');

      // scroll to the last column of the tbody, where the form will start
      FCH.smoothScroll($parent.find('tbody tr:last-child'), 500, 100, 90);

      _this._addEditActions($this, $parent);
    });
  },

  _addEditActions: function(field, $parent) {
    var $this = $(field);
    var $wrapper = $parent.find('.js-addedit-form-wrapper');

    $.get($this.attr('href'), function(data){
      // check to see if the content is hidden and slide it down if it is.
      if( $wrapper.is(':hidden') ) {
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

      $wrapper.find('.hint').hinter();
    });
  },

  // Once form is submitted and receives a successful AJAX response, replace form data and initialize listeners on nested elements
  addEditSubmission: function() {
    var _this = this;

    this.$addedit_form.on('ajax:success', function(evt, data, status, xhr){

      var $target = $(evt.target);

      // ignore calls not returning html
      if (data !== ' ' && $(data)[0]) {
        var $this = $(this);
        var $html = $(data);

        // remotipart returns data inside textarea, let's grab it from there
        if ( $html.is('textarea') ) {
          $html = $( $html.val() );
        }

        if( $html && ($html.hasClass('main_content-section-area') || $html.hasClass('js-index-addedit-form')) ) {
          // we're returning the table, replace everything
          var replacementHTML;

          // Response is different between the js-index-addedit-form and the nested association form
          if( $html.hasClass('main_content-section-area') ) {
            replacementHTML = $html[1].innerHTML;
          } else {
            replacementHTML = $html[0].innerHTML;
          }

          _this._addEditReplaceAndReinit($this, replacementHTML, $target);

        } else if( $html.hasClass('form_content-wrapper') ) {
          // we're returning the form due to an error, just replace the form
          $this.find('.form_content-wrapper').replaceWith(data);
          $this.find('.select select').fae_chosen();
          $this.find('.input.file').fileinputer();

          FCH.smoothScroll($this.find('.js-addedit-form-wrapper'), 500, 100, 120);
        }

        _this.deleteNoForm();
        if( _this.$filter_form.length ) {
          _this.filterSelect();
          _this.filterSubmission();
        }

        Fae.navigation.fade_notices();

      } else if ($target.hasClass('js-asset-delete-link')) {
        // handle remove asset links
        $target.parent().fadeOut('fast', function() {
          $(this).next('.asset-inputs').fadeIn('fast');
        });
      }
    });
  },

  // Replace AJAX'd form and add calls to all new HTML elements
  // @param $el {jQuery Object} - object to be replaced
  // @param html {String} - new HTML
  // @param $target {jQuery Object} - original form wrapper
  _addEditReplaceAndReinit: function($el, html, $target) {
    var $form_wrapper = $el.find('.js-addedit-form-wrapper');

    // Private function replaces parent element with HTML and reinits select and sorting
    var regenerateHTML = function() {
      // .html() is not replacing it properly
      $el.get(0).innerHTML = html;
      $el.find('.select select').fae_chosen();
      Fae.tables.rowSorting();
    };

    // if there's a form wrap, slide it up before replacing content
    if ($form_wrapper.length) {
      $form_wrapper.slideUp(regenerateHTML);

    } else {
      regenerateHTML();
    }

    if( !$target.hasClass('js-delete-link') ) {
      FCH.smoothScroll($el.parent(), 500, 100, 120);
    }
  },

  filterSubmission: function() {
    var _this = this;
    _this.$filter_form
      .on('ajax:success', function(evt, data, status, xhr){
        $(this).next('table').replaceWith( $(data).find('table').first() );
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

  applyCookies: function() {
    var cookie_key = $('.js-filter-form').data('cookie-key');

    if (cookie_key) {
      var set_cookie = $.cookie(cookie_key);
      if (set_cookie && (set_cookie.length > 2)) {
        var cookie = JSON.parse(set_cookie);
        var keys = Object.keys(cookie)
        var hash = '?';

        for(var i = 0; i < keys.length; i++) {
          if(hash !== '?') {
            hash += '&';
          }
          hash += keys[i] + '=' + cookie[keys[i]];
        }

        if( hash !== '?') {
          window.location.hash = hash;
        }
      }

      this.grind = new Grinder(this._setFilterDropdowns);
    }
  },

  // update hash when filter dropdowns changed
  filterSelect: function(){
    var _this = this;
    $('.js-filter-form .table-filter-group').on('change', function(){
      if( $('.js-filter-form').data('cookie-key') ) {
        var key = $(this).find('select').attr('id').split('filter_')[1];
        var value = $(this).find('option:selected').val();

        _this.grind.update(key, value, false, true);
      }
    });
  },

  // check for cookie or hash and set dropdowns/ url accordingly
  // callback for Grinder
  _setFilterDropdowns: function(params) {
    var cookie_name = $('.js-filter-form').data('cookie-key');
    $.cookie(cookie_name, JSON.stringify(params));

    if( !$.isEmptyObject(params) ) {
      $.each(params, function(k, v) {
        $('.js-filter-form .table-filter-group').each(function(){
          var $this = $(this);
          var key = $this.find('select').attr('id').split('filter_')[1];
          var value = $this.find('option:selected').val();

          if( k === key ) {
            $this.find('option').each(function(){
              if( $this.val() === v ) {
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

  deleteNoForm: function() {
    // on deletes that don't exist in a form like file upload area
    $('.js-asset-delete-link').on('ajax:success', function(){
      var $this = $(this);
      if( !$this.closest('.js-addedit-form-wrapper').length ) {
        var $parent = $this.closest('.asset-actions');

        $parent.fadeOut(function(){
          $parent.next('.asset-inputs').fadeIn();
        });
      }
    });
  },

  //ajax image delete links
  imageDeleteLinks: function() {
    $('.imageDeleteLink').click(function(e) {
      e.preventDefault();
      var $this = $(this);

      if( confirm('Are you sure you want to delete this image?') ) {
        $.post($this.attr('href'), 'html');
        $this.parent().next().show();
        $this.parent().hide();
      }
    });
  },

  // attaching click handlers to #main_content to allow ajax replacement
  htmlListeners: function() {
    $('#main_content')

      // for the yes/no slider
      .on('click', '.slider-wrapper', function(e){
        e.preventDefault();
        $(this).toggleClass('slider-yes-selected');
      })

      // The settings menu for tables and checkboxe
      .on('click', '.main_table-action_menu-trigger, .boolean label, .checkbox_collection--vertical label, .checkbox_collection--horizontal label', function(e){
        $(this).toggleClass('js-active');
      })

      // stop the event bubbling and running the above toggleClass twice
      .on('click', '.boolean :checkbox, .checkbox_collection--vertical :checkbox, .checkbox_collection--horizontal :checkbox', function(e){
        e.stopPropagation();
      });
  }
};
