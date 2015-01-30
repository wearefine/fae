var AjaxForms = {

  init: function() {
    this.set_elements();
    this.addedit_links();
    this.addedit_submission();
    this.delete_no_form();
    if (this.$filter_form.length) {
      this.filter_submission();
    }
  },

  set_elements: function() {
    this.$addedit_form = $('.js-addedit-form');
    this.$filter_form = $('.js-filter-form');
  },

  addedit_links: function() {
    this.$addedit_form.on('click', '.js-add-link, .js-edit-link', function(ev) {
      ev.preventDefault();
      var $this = $(this);
      var $parent = $this.closest('.js-addedit-form');
      var $wrapper = $parent.find('.js-addedit-form-wrapper');

      // scroll to the last column of the tbody, where the form will start
      Admin.scroll_to($parent.find("tbody tr:last-child"), 90);

      $.get($this.attr('href'), function(data){
        // check to see if the content is hidden and slide it down if it is.
        if ($wrapper.is(":hidden")) {
          // replace the content of the form area and initiate the chosen and fileinputer
          $wrapper.html(data).find(".select select").fae_chosen({ width: '300px' });
          $wrapper.find(".input.file").fileinputer({delete_class: "icon-delete_x file_input-delete"});
          $wrapper.slideDown();
        } else {
          // if it is visible, replace its content by retaining height
          $wrapper.height($wrapper.height());

          // replace the content of the form area and then remove that height and then chosen and then fileinputer
          $wrapper.html(data).css("height", "").find(".select select").fae_chosen();
          $wrapper.find(".input.file").fileinputer({delete_class: "icon-delete_x file_input-delete"});
        }

        $wrapper.find(".hint").hinter();
      });
    });
  },

  addedit_submission: function() {
    this.$addedit_form.on('ajax:success', function(evt, data, status, xhr){

      $target = $(evt.target);

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

        if ($(html)[2] && $(html)[2].className === 'main_content-section-area') {
          // we're returning the table, replace everything

          var $form_wrapper = $(this).find('.js-addedit-form-wrapper');

          // if there's a form wrap, slide it up before replacing content
          if ($form_wrapper.length) {
            $form_wrapper.slideUp(function(){
              AjaxForms.addedit_replace_and_reinit($this, $(html)[2].innerHTML, $target);
            });
          } else {
            AjaxForms.addedit_replace_and_reinit($this, $(html)[2].innerHTML, $target);
          }

          if (!$target.hasClass("js-delete-link")) {
            Admin.scroll_to($parent);
          }
        } else if ($(html)[0].className === 'form_content-wrapper') {
          // we're returning the form due to an error, just replace the form
          $this.find('.form_content-wrapper').replaceWith(html);
          $this.find('.select select').fae_chosen();
          $this.find(".input.file").fileinputer({delete_class: "icon-delete_x file_input-delete"});

          Admin.scroll_to($this.find('.js-addedit-form-wrapper'));
        }

        AjaxForms.init();
        Admin.fade_notices();

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

    Admin.sortable();
  },

  filter_submission: function() {
    this.$filter_form
      .on('ajax:success', function(evt, data, status, xhr){
        $(this).next('table').replaceWith($(data).find('table'));
      })
      .on('click', '.js-reset-btn', function(ev) {
        var form = $(this).closest('form')[0];
        form.reset();
        $(form).find('select').val('').trigger('chosen:updated');
      });
  },

  delete_no_form: function() {
    // on deletes that don't exist in a form like file upload area
    $('.js-asset-delete-link').on('click', function(){
      var $this = $(this);
      if (!$this.closest('.js-addedit-form-wrapper').length) {
        var $parent = $this.closest('.asset-actions');
        var $inputs = $parent.next('.asset-inputs');
        $parent.fadeOut(function(){
          $inputs.fadeIn();
        });
      }
    });
  }
};