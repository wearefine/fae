/* global Fae */

'use strict';

Fae.form = {

  init: function() {
    this.dates.init();
    this.text.init();
    this.select.init();
    $("th.main_table-checkbox").checkboxer();

    this.validator.init();
    this.cancel.init();
    this.ajax.init();
    if ($('table.main_table-sort_columns').length) {
      Fae.form.set_date_class.init();
    }
  },

};
