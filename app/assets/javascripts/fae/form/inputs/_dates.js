/* global Fae, datepicker, FCH */

/**
 * Fae form dates
 * @namespace form.dates
 * @memberof form
 */
Fae.form.dates = {

  init: function() {
    this.initDatepicker();
    this.initDateRangePicker();
  },

  /**
   * Initialize date picker
   */
  initDatepicker: function() {
    $('.datepicker input').datepicker({
      dateFormat: 'M dd, yy',
      inline: true,
      showOtherMonths: true,
      dayNamesMin: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    });
  },

  /**
   * Initialize date range picker
   */
  initDateRangePicker: function() {
    $.dateRangePickerLanguages['custom'] = {
      'selected': 'Choosed:',
      'days': 'Days',
      'apply': 'Close',
      'week-1' : 'Mon',
      'week-2' : 'Tue',
      'week-3' : 'Wed',
      'week-4' : 'Thu',
      'week-5' : 'Fri',
      'week-6' : 'Sat',
      'week-7' : 'Sun',
      'month-name': ['January','February','March','April','May','June','July','August','September','October','November','December'],
      'previous' : 'Previous',
      'prev-week' : 'Week',
      'prev-month' : 'Month',
      'prev-quarter' : 'Quarter',
      'prev-year' : 'Year',
      'less-than' : 'Date range should longer than %d days',
      'more-than' : 'Date range should less than %d days',
      'default-more' : 'Please select a date range longer than %d days',
      'default-less' : 'Please select a date range less than %d days',
      'default-range' : 'Please select a date range between %d and %d days',
      'default-default': 'Please select a date'
    };

    // daterangepicker instantiation
    if (FCH.exists('.daterangepicker')) {
      $('.daterangepicker').dateRangePicker({
        format: 'MMM DD, YYYY',
        separator : ' to ',
        showShortcuts: false,
        language: 'custom',
        getValue: function() {
          if ($('.js-start_date').val() && $('.js-end_date').val()) {
            return $('.js-start_date').val() + ' to ' + $('.js-end_date').val();
          } else {
            return '';
          }
        },
        setValue: function(s,s1,s2) {
          $('.js-start_date').val(s1);
          $('.js-end_date').val(s2);
        }
      });
    };
  },

};
