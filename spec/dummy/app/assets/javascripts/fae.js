// This file is compiled into fae/application.js
// use this as another manifest file if you have a lot of javascript to add
// or just add your javascript directly to this file

// Uncomment the following line if you want to use Trumbowyg HTML Editor
//= require fae/vendor/trumbowyg

$(document).ready(function(){
  $('.login-body').addClass('test-class');

  $("body").on("modal:data_loaded", function (e) {
    console.log(e);
  });

  $("body").on("modal:opened", function (e) {
    console.log(e);
  });

  $("body").on("modal:show", function (e) {
    console.log(e);
  });

  $("body").on("modal:closed", function (e) {
    console.log(e);
  });
});
