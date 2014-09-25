var Admin = {

    breakpoints: {
      desktop: 800
    },

  init: function(){
    var that = this;

    $("select").each(function(index, elm){
      var $select = $(this);
      if($select.hasClass("multiselect")) {
        $select.multiSelect({
          selectableHeader: "<div class='custom-header'>80 Available Items</div>",
          selectionHeader: "<div class='custom-header'>5 Added Items</div>"
        });
      } else {
        $select.chosen();
      }
    });

    $(".datepicker input").datepicker({
      inline: true,
      showOtherMonths: true,
      dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    });

    // daterangepicker instantiation
    $(".daterangepicker").dateRangePicker({
      format: "MMM Do, YYYY",
      separator: ' - '
    });

    Admin.image_delete_links();

    // input type=file customization
    $(".input.file").fileinputer({delete_class: "icon-delete_x file_input-delete"});

    // make all the hint areas
    $(".hint").hinter();

    // checkboxes customizaitons
    $("th.main_table-checkbox").checkboxer();

    // sticket header for the content area
    $(".main_content-header").sticky({ offset: 0, min_desktop: true });
    $("#main_nav").sticky({ offset: 0, make_placeholder: false, min_desktop: true});

    // sort columns in tables if applicable
    $(".main_table-sort_columns").tablesorter();
    $(".main_table-sort_columns-cities").tablesorter({
      sortList: [[1,0]]
    });

    // button dropdown class toggle
    $(".button-dropdown").click(function(){
      $(this).toggleClass("button-dropdown--opened");
    });

    // button dropdown click anywhere but the dropdown close
    $("body").click(function(e){
      if ($(e.target).closest(".button-dropdown").length === 0) {
        $(".button-dropdown").removeClass("button-dropdown--opened");
      }
    });

    // scroll_to event for non-ajax'd table forms
    $(".table-add-link-visible").click("on", function(){
      var $parent = $(this).closest('section');
      that.scroll_to($parent.find("tbody tr:last-child"), 90);
    });

    var HotelStatusClasser = function(select){
      var $status = $(select).closest(".hotel_status");
      var status_class = "hotel_status-coming_soon";
      var status_text = "coming soon"; // all lower case
      var selected_text = $(select).find("option:selected").text().toLowerCase();

      // if the selected option text is the same as the status text
      $status.toggleClass(status_class, selected_text === status_text);
    };

    // on load, if hotel status is 'coming soon' add the appropriate class
    $(".hotel_status select").each(function(){
      HotelStatusClasser(this);

      //hide show "Reservation Starting"
      $(this).on("change", function(){
        HotelStatusClasser(this);
      });
    });

    //image modals
    $(".js-image-modal").click(function(e){
      e.preventDefault();
      var that = this;
      // grab the image container and image
      var $image_container = $(this).next(".image-modal-container");
      var $image = $image_container.find("img");

      // only create the image if it is not there
      if ($image_container.length === 0) {
        // create teh image container and image if not there
        $image_container = $(document.createElement("div")).addClass("image-modal-container").css({
          position: "absolute",
          left: "-9999px"
        });
        $image = $(document.createElement("img")).attr("src", $(that).attr("href"));
        $image.appendTo($image_container);
        $image_container.insertAfter($(this));
      }
      // when the image is loaded then slap it up in a modal
      $image_container.imagesLoaded().done(function(){
        $image.modal({
          minHeight: $image.height() + 80,
          minWidth: $image.width() + 40,
          overlayClose: true
        });
      });
    });

    // Login page checkbox
    $(".login-body").on('click', 'label.boolean', function(e){
      $(this).toggleClass("js-active");
    }).on('click', '.input.boolean :checkbox', function(e){
      e.stopPropagation();
    });

    // attaching click handlers to #main_content to allow ajax replacement
    $('#main_content')
      // for the yes/no slider
      .on('click', '.slider-wrapper', function(e){
        e.preventDefault();
        $(this).toggleClass("slider-yes-selected");
      })
      // The settings menu for tables
      .on('click', '.main_table-action_menu-trigger', function(e){
        $(this).toggleClass("js-active");
      })
      // for checkboxes
      .on('click', '.checkbox_collection--vertical label, .checkbox_collection--horizontal label', function(e){
        $(this).toggleClass("js-active");
      })
      // stop the event bubbling and running the above toggleClass twice
      .on('click', '.checkbox_collection--vertical :checkbox, .checkbox_collection--horizontal :checkbox', function(e){
        e.stopPropagation();
      })
      // for ajax forms. gotta hijack before it's submitted for some slide up action.
      .on('click', '.js-addedit-form-wrapper input[type=submit]', function(e){
        // e.preventDefault();
        // var $form = $(this).closest('form');
        // that.scroll_to($(this).closest('.js-addedit-form'));
        // $(this).closest('.js-addedit-form-wrapper').slideUp(function(){
        //   $form.submit();
        //   that.sortable();
        // });
      });

    // Run through the checkboxes and see if they are checked. apply js class for styling.
    $('.checkbox_collection--vertical label, .checkbox_collection--horizontal label').each(function(){
      if ($(this).find(":checkbox:checked").length > 0) {
        $(this).addClass("js-active");
      }
    });

    // utility nav drop down
    $('.utility_nav-user > a, .utility_nav-view > a').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      var $sub_nav = $(this);

      // there could be more than one. so remove all of the clicked statuses and add to the specific one
      $('.utility_nav-clicked').removeClass('utility_nav-clicked');
      $sub_nav.addClass('utility_nav-clicked');

      // assign a once function to close the menus
      $(document).on('click.utility_nav', function(e){
        // as long as the click is not in the menu
        if ($(e.target).closest('.utility_sub_nav').length === 0) {
          // remove the class from the utility nav
          $sub_nav.removeClass('utility_nav-clicked');

          // unbind the click from the document, no need to keep it around.
          $(document).off('click.utility_nav');
        }
      });
    });

    this.sortable();
    this.fade_notices();
    this.city_district_selector();
    this.slugger();
    this.ad_form.init();
  },

  sortable: function() {
    //Make table Sortable by user
    $(".main_content-sortable").sortable({
      items: "tbody tr",
      opacity: 0.8,
      handle: (".main_content-sortable-handle"),

      //helper funciton to preserve the width of the table row
      helper: function(e, tr) {
        var $originals = tr.children();
        var $helper = tr.clone();
        var $ths = $(tr).closest("table").find("th");

        $helper.children().each(function(index) {
          // Set helper cell sizes to match the original sizes
          $(this).width($originals.eq(index).width());
          //set the THs width so they don't go collapsey
          $ths.eq(index).width($ths.eq(index).width());
        });
        return $helper;
      },

      // on stop, set the THs back to no inline width for repsonsivity
      stop: function(e, ui) {
        $(ui.item).closest("table").find("th").css("width", "");
      },

      update: function() {
        var $this = $(this);
        var serial = $this.sortable('serialize');
        var object = serial.substr(0, serial.indexOf('['));

        $.ajax({
          url: '/'+Admin.path+'/sort/'+object,
          type: 'post',
          data: serial,
          dataType: 'script',
          complete: function(request){
            // sort complete messaging can go here
          }
        });
      }
    }).disableSelection();
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

  scroller: function(elm) {
    if (location.pathname.replace(/^\//,'') == elm.pathname.replace(/^\//,'') && location.hostname == elm.hostname) {
      var target = $(elm.hash);
      target = target.length ? target : $("[name=" + elm.hash.slice(1) + "]");

      if (target.length) {
        var newScrollTop = target.offset().top - 116;
        $("html, body").animate({ scrollTop: newScrollTop }, 500);
        return false;
      }
    }
  },

  scroll_to: function(to_elm, adjustment) {
    if (typeof adjustment == 'undefined') {
      // set the default adjustment
      adjustment = 130;
    }
    $('html, body').animate({
      scrollTop: $(to_elm).offset().top - adjustment
    }, 500);
  },

  fade_notices: function() {
    $('.notice').delay(3000).slideUp('fast');
  },

  city_district_selector: function() {
    var $city_select = $('.js-city-selector');
    var $district_select_wrap = $('.js-district-selector');


    $district_select_wrap.hide();
    Admin.update_district_select($district_select_wrap, $city_select.val());

    $city_select.on('change', function() {
      Admin.update_district_select($district_select_wrap, $city_select.val());
    });
  },

  update_district_select: function($district_select_wrap, city_id) {
    var $city_options = $district_select_wrap.find('option[data-city='+city_id+']');
    if (city_id && $city_options.length) {
      $district_select_wrap.find('option:not(:first)').addClass('chosen-hide');
      $city_options.removeClass('chosen-hide');
      $district_select_wrap.find('select').trigger("chosen:updated");
      // $district_select_wrap.find('span.error').remove();
      $district_select_wrap.fadeIn('fast');
    } else {
      $district_select_wrap.fadeOut('fast');
    }
  },

  slugger: function() {
    var slug_text = null;
    var $slug = $('.slug');
    if ($slug.val() !== '') {
      $('.slugger').removeClass('slugger');
      $('.select-slugger').removeClass('select-slugger');
    }
    $('.slugger').keyup(function(){
      slug_text = Admin.digest_slug();
      $slug.val(slug_text);
    });
    $('.select-slugger').change(function(){
      slug_text = Admin.digest_slug();
      $slug.val(slug_text);
    });
  },

  digest_slug: function() {
    var slug_text = $('.slugger').val();
    var city = $('.select-slugger').find('option:selected').html();
    if (city) {
      slug_text += ' '+city;
    }
    slug_text = slug_text.toLowerCase().replace('.','').replace(/[^a-zA-Z0-9.]+/g,'-');
    return slug_text;
  },

  ad_form: {
    init: function() {
      if ($('#new_ad, .edit_ad').length) {
        Admin.ad_form.$type_select = $('#ad_ad_type_id');
        Admin.ad_form.$ad_fields = $('div.ad-fields-wrapper');

        Admin.ad_form.toggle_fields(0);

        Admin.ad_form.$type_select.change(function() {
          Admin.ad_form.toggle_fields(200);
        });
      }
    },

    toggle_fields: function(fade_speed) {
      if (Admin.ad_form.$type_select.val() == '') {
        Admin.ad_form.$ad_fields.hide();
      } else {
        Admin.ad_form.$ad_fields.fadeOut(fade_speed, function() {
          $('div[data-types]').hide();
          $('div[data-types~='+Admin.ad_form.$type_select.val()+'], div[data-types=all]').show();
          Admin.ad_form.$ad_fields.fadeIn(fade_speed);
        });
      }
    },

    $type_select: '',
    $ad_fields: ''
  }
};


$(function() {
  Accordion.init();
  Admin.init();
  AjaxForms.init();
  SubnavHighlighter.init();
});