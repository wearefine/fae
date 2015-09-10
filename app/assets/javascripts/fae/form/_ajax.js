/* global Fae */

'use strict';

Fae.form.ajax = {

  init: function() {
    this.set_elements();
    if(!this.has_reinit) {
      this.nested_addedit_links();
      this.nested_addedit_submission();
      this.index_addedit_links();
      this.index_addedit_submission();
    }
    this.delete_no_form();
    this.apply_cookies();
    if (this.$filter_form.length) {
      this.filter_select();
      this.filter_submission();
    }
    this.image_delete_links();
  },

  has_reinit: false,

  set_elements: function() {
    this.$addedit_form = $('.js-addedit-form');
    this.$index_addedit_form = $('.js-index-addedit-form');
    this.$filter_form = $('.js-filter-form');
  },

  nested_addedit_links: function() {
    this.$addedit_form.on('click', '.js-add-link, .js-edit-link', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $parent = $this.closest('.js-addedit-form');

      // scroll to the last column of the tbody, where the form will start
      Fae.helpers.scroll_to($parent.find("tbody tr:last-child"), 90);

      Fae.form.ajax.addedit_actions($this, $parent);
    });
  },

  index_addedit_links: function() {
    this.$index_addedit_form.on('click', '.js-add-link, .js-edit-link', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $parent = $('.js-addedit-form');

      // scroll to the last column of the tbody, where the form will start
      Fae.helpers.scroll_to($parent.find("tbody tr:last-child"), 90);

      Fae.form.ajax.addedit_actions($this, $parent);
    });
  },

  addedit_actions: function(field, parent) {
    var $this = $(field);
    var $wrapper = $(parent).find('.js-addedit-form-wrapper');

    $.get($this.attr('href'), function(data){
      // check to see if the content is hidden and slide it down if it is.
      if ($wrapper.is(":hidden")) {
        // replace the content of the form area and initiate the chosen and fileinputer
        $wrapper.html(data).find(".select select").fae_chosen({ width: '300px' });
        $wrapper.find(".input.file").fileinputer();
        $wrapper.slideDown();
      } else {
        // if it is visible, replace its content by retaining height
        $wrapper.height($wrapper.height());

        // replace the content of the form area and then remove that height and then chosen and then fileinputer
        $wrapper.html(data).css("height", "").find(".select select").fae_chosen();
        $wrapper.find(".input.file").fileinputer();
      }

      Fae.form.dates.date_picker();
      Fae.form.dates.daterange_picker();
      Fae.form.text.slugger();

      $wrapper.find(".hint").hinter();
    });
  },

  nested_addedit_submission: function() {
    var _this = this;

    this.$addedit_form.on('ajax:success', function(evt, data, status, xhr){

      var $target = $(evt.target);

      // ignore calls not returning html
      if (data !== ' ' && $(data)[0]) {
        var $this = $(this);
        var $parent = $this.parent();
        // we're manipulating the return so let's store in a var and keep 'data' intact
        var html = data;

        // remotipart returns data inside textarea, let's grab it from there
        if ($(html)[0].localName === 'textarea') {
          html = $(data)[0].value;
        }

        if ($(html)[1] && $(html)[1].className === 'main_content-section-area') {
          // we're returning the table, replace everything

          var $form_wrapper = $this.find('.js-addedit-form-wrapper');

          // if there's a form wrap, slide it up before replacing content
          if ($form_wrapper.length) {
            $form_wrapper.slideUp(function(){
              _this.addedit_replace_and_reinit($this, $(html)[1].innerHTML, $target);
            });
          } else {
            _this.addedit_replace_and_reinit($this, $(html)[1].innerHTML, $target);
          }

          if (!$target.hasClass("js-delete-link")) {
            Fae.helpers.scroll_to($parent);
          }
        } else if ($(html)[0].className === 'form_content-wrapper') {
          // we're returning the form due to an error, just replace the form
          $this.find('.form_content-wrapper').replaceWith(html);
          $this.find('.select select').fae_chosen();
          $this.find(".input.file").fileinputer();

          Fae.helpers.scroll_to($this.find('.js-addedit-form-wrapper'));
        }

        _this.has_reinit = true;
        _this.init();
        Fae.fade_notices();

      } else if ($target.hasClass("js-asset-delete-link")) {
        // handle remove asset links
        $target.parent().fadeOut('fast', function() {
          $(this).next('.asset-inputs').fadeIn('fast');
        });
      }
    });
  },

  index_addedit_submission: function() {
    var _this = this;

    this.$index_addedit_form.on('ajax:success', function(evt, data, status, xhr){

      var $target = $(evt.target);

      // ignore calls not returning html
      if (data !== ' ' && $(data)[0]) {
        var $this = $(this);
        var $parent = $this.parent();

        // we're manipulating the return so let's store in a var and keep 'data' intact
        var html = data;

        if ($(html)[0] && $(html)[0].className === 'js-index-addedit-form') {
          // we're returning the table, replace everything

          var $form_wrapper = $this.find('.js-addedit-form-wrapper');

          // if there's a form wrap, slide it up before replacing content
          if ($form_wrapper.length) {
            $form_wrapper.slideUp(function(){
              _this.addedit_replace_and_reinit($this, $(html)[0].innerHTML, $target);
            });
          } else {
            _this.addedit_replace_and_reinit($this, $(html)[0].innerHTML, $target);
          }

          if (!$target.hasClass("js-delete-link")) {
            Fae.helpers.scroll_to($parent);
          }
        }

        _this.has_reinit = true;
        _this.init();
        Fae.fade_notices();

      } else if ($target.hasClass("js-asset-delete-link")) {
        // handle remove asset links
        $target.parent().fadeOut('fast', function() {
          $(this).next('.asset-inputs').fadeIn('fast');
        });
      }
    });
  },

  addedit_replace_and_reinit: function($this, html, $target) {
    $this.html(html)
      .find(".select select").fae_chosen();

    Fae.tables.rowSorting();
  },

  filter_submission: function(params) {
    var _this = this;
    _this.$filter_form
      .on('ajax:success', function(evt, data, status, xhr){
        $(this).next('table').replaceWith($(data).find('table').first());
      })
      .on('click', '.js-reset-btn', function(ev) {
        var form = $(this).closest('form')[0];
        form.reset();
        $(form).find('select').val('').trigger('chosen:updated');
        // reset hashies
        window.location.hash = ''
      })
      .on('change', 'select', function() {
        _this.$filter_form.submit();
      });
  },

  apply_cookies: function() {
    var _this = this;
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

      var callback = function(params){
        $.cookie(cookie_key, JSON.stringify(params));

        var hash = window.location.hash;
        Fae.form.ajax.set_filter_dropdowns(hash);
      }

      _this.grind = new Grinder(callback);
    }
  },

  // update hash when filter dropdowns changed
  filter_select: function(){
    var _this = this;
    $('.js-filter-form .table-filter-group').on('change', function(){
      if ($('.js-filter-form').data('cookie-key')) {
        var key = $(this).find('select').attr('id').split('filter_')[1];
        var value = $(this).find('option:selected').val();

        _this.grind.update(key, value, false, true);
      }
    });
  },

  // check for cookie or hash and set dropdowns/ url accordingly
  set_filter_dropdowns: function(hash) {
    var cookie_name = $('.js-filter-form').data('cookie-key')
    if (cookie_name) {
      var parsed = JSON.parse($.cookie(cookie_name));
    } else {
      var parsed = this.grind.parse(hash);
    }

    if (!$.isEmptyObject(parsed)) {
      $.each(parsed, function(k, v){
        $('.js-filter-form .table-filter-group').each(function(){
          var key = $(this).find('select').attr('id').split('filter_')[1];
          var value = $(this).find('option:selected').val();
          if (k == key) {
            $(this).find('option').each(function(){
              if ($(this).val() == v) {
                $(this).prop('selected', 'selected');
                $('#filter_' + key).trigger('chosen:updated');
              };
            });
          }
        });
      });
      $('.js-filter-form').submit();
    }
  },

  delete_no_form: function() {
    // on deletes that don't exist in a form like file upload area
    $('.js-asset-delete-link').on('ajax:success', function(){
      var $this = $(this);
      if (!$this.closest('.js-addedit-form-wrapper').length) {
        var $parent = $this.closest('.asset-actions');
        var $inputs = $parent.next('.asset-inputs');
        $parent.fadeOut(function(){
          $inputs.fadeIn();
        });
      }
    });
  },

  //ajax image delete links
  image_delete_links: function() {
    $('.imageDeleteLink').click(function(e) {
      e.preventDefault();
      if (confirm('Are you sure you want to delete this image?')) {
        $.post($(this).attr('href'),'html');
        $(this).parent().next().show();
        $(this).parent().hide();
      }
    });
  },
};
