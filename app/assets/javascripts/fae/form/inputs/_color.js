/* global Fae, colorpicker, FCH */

/**
 * Fae form color
 * @namespace form.color
 * @memberof form
 */

Fae.form.color = {
  init: function() {
    this.initColorpicker();
  },

  /**
   * Initialize colorpicker
   */
  initColorpicker: function() {
    var settings = {
      positionCallback: function($elm) {
        var inputOffset = $elm.offset().top;
        var distanceToBottom = $(document).height() - inputOffset;
        var top = distanceToBottom <= this.$UI._height ? 414 : inputOffset + $elm.innerHeight();

        return { left: 30, top: top }
      },
      renderCallback: function($elm, toggled) {
        var colors = this.color.colors;

        // default to HEX if Alpha is 1
        if ($elm.val() && colors.alpha > 0.9) {
          $elm.val('#' + colors.HEX);
        }
      }
    }

    $('.color').colorPicker(settings);
  }
};
