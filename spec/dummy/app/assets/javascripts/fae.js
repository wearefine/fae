// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file

// Uncomment the following line if you want to use Trumbowyg HTML Editor
//= require fae/vendor/trumbowyg

$(document).ready(function(){
  $('.login-body').addClass('test-class');

  $("body").on("modal:show", function (e) {
    $('.modal-callback').remove();
    $(e.relatedTarget).closest('.input').append("<p class='modal-callback modal-callback--show'>Modal Open/Show</p>");

    //Add form listeners & close form on ajax success
    if (e.dialog.data[0].classList.contains('nested-form')) {
      Fae.form.ajax.htmlListeners();

      $('#fae-modal').on('ajax:success', function (evt, data, status, xhr) {
        if (Fae.modals.modalOpen) {
          $.modal.close();
        }
      });
    }
  });

  $("body").on("modal:shown", function (e) {
    $(e.relatedTarget).closest('.input').append("<p class='modal-callback modal-callback--shown'>Modal Shown</p>");
  });


  $("body").on("modal:close", function (e) {
    $(e.relatedTarget ).closest('.input').append( "<p class='modal-callback modal-callback--close'>Modal Close</p>" );
  });

  $("body").on("modal:closed", function (e) {
    $(e.relatedTarget).closest('.input').append("<p class='modal-callback modal-callback--closed'>Modal Closed</p>");
  });
});
