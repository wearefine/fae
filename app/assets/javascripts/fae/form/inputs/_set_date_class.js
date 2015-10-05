/* global Fae */

Fae.form.set_date_class = {

  init: function() {
    this.set_class();
  },

  set_class: function() {
    var _this = this;
    $.each($('tbody tr td'), function(){
      _this.test_date($(this));
    });
  },

  test_date: function(td){
    var str = td.text()
    var date_format = str.match(/^(\d{2})\/(\d{2})\/(\d{2})$/);
    if (date_format === null) {
      return false;
    } else {
      var $th = td.closest('table').find('th').eq(td.index());
      $th.not('.sorter-mmddyy').addClass('sorter-mmddyy');
    }
  }

};
