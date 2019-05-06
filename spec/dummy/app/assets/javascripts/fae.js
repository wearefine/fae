// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file

// Uncomment the following line if you want to use Trumbowyg HTML Editor
//= require fae/vendor/trumbowyg

$(document).ready(function(){
  $('.login-body').addClass('test-class');

  $("body").on("modal:show", function (e) {
    $( e.relatedTarget ).closest('.input').append( "<p class='modal-callback'>Modal Open/Show</p>" );
  });

  $("body").on("modal:open", function (e) {
    $(e.relatedTarget).closest('.input').append("<p class='modal-callback'>Modal Opened</p>");
  });


  $("body").on("modal:close", function (e) {
    $( e.relatedTarget ).closest('.input').append( "<p class='modal-callback'>Modal Close</p>" );
  });

  $("body").on("modal:closed", function (e) {
    $(e.relatedTarget).closest('.input').append("<p class='modal-callback'>Modal Closed</p>");
  });
});
