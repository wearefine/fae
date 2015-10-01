/* global Fae, FCH */

'use strict';

/**
 * Fae navigation accordion
 * @namespace navigation.accordion
 * @memberof navigation
 */
Fae.navigation.accordion = {

  init: function() {
    this.accordionClickEventListener();
  },

  /**
   * Attach click listener to main and sub links
   */
  accordionClickEventListener: function() {
    var _this = this;

    $('.main_nav-accordion .main_nav-link, .sub_nav-accordion .main_nav-sub-link.with-third_nav').click(function(e) {
      e.preventDefault();

      var $this = $(this);
      var $parent = _this._linkParent($this);
      var was_opened = $parent.hasClass('accordion-open');

      // close all first
      // only get the first class name and add a leading period
      $parent.siblings().each(function() {
        _this.close($(this));
      });

      if (!was_opened) {
        // open the clicked item if it was not just opened
        _this.open($parent);
      } else if ($this.hasClass('main_nav-link') || $this.hasClass('main_nav-sub-link')) {
        _this.close($parent);
      }
    });
  },

  /**
   * Find closest subnav within an accordion
   * @access protected
   * @param {jQuery} $el - Accordion wrapper
   * @return {jQuery} Subnav element
   */
  _subNav: function($el) {
    return $el.find('.main_nav-sub-nav, .main_nav-third-nav').first();
  },

  /**
   * Find closest accordion wrapper
   * @access protected
   * @param {jQuery} $el - Sublink of accordion wrapper
   * @return {jQuery} Accordion wrapper
   */
  _linkParent: function($el) {
    if($el.hasClass('main_nav-sub-link')) {
      return $el.parent().first();
    } else {
      return $el.parentsUntil('.main_nav-accordion').parent().first();
    }
  },

  /**
   * Open accordion panel
   * @param {jQuery} $el - Accordion wrapper
   */
  open: function($el) {
    $el.addClass('accordion-open');
    this._subNav($el).stop().slideDown();
  },

  /**
   * Close accordion panel
   * @param {jQuery} $el - Accordion wrapper
   */
  close: function($el) {
    $el.removeClass('accordion-open');
    this._subNav($el).stop().slideUp();
  },
};
