/* global Fae, FCH */

/**
 * Fae navigation
 * @namespace navigation.peek
 * @memberof navigation
 */
Fae.navigation.peek = {

  init: function() {
    this.$body = $('body');
    this.$mainHeader = $('#js-main-header');
    this.$mainContent = $('#js-main-content');

    this.isPeekActive = false;
    this.topTransitionRule = 'top .4s ease';
    this.peekClass = 'main-header--peek';
    this.scrolledClass = 'main-header--scrolled_past';
    this.prevScrollTop = this.$body.prop('scrollTop');

    this._bind();
  },

  getPeekHeight: function() {
    return this.isPeekActive ? this.$mainHeader.outerHeight() : 0;
  },

  _bind: function() {
    FCH.scroll.push(this._peekNavListener.bind(this));
  },

  _peekNavListener: function() {
    // Fizzle & reset if we're below large size
    if (!FCH.bp.large) { this._disablePeek(true); return; }

    // Fizzle & reset if we aren't low enough on page
    const scrollTop = $(window).scrollTop();
    if (scrollTop <= this.$mainHeader.outerHeight()) {
      this._disablePeek(true);
      this._trackPeekPos(scrollTop);
      return;
    } else {
      if (!this.$mainHeader.hasClass(this.scrolledClass)) {
        this._hackyDisableTopAnim();
      }
      this._mainHeaderPlaceholder(true);
    }

    // Figure scroll direction
    // Guard against elastic-Safari scrolling by refusing to peek nav if
    // too close to the bottom of the page. Ugh. Eyerolls for days
    if (scrollTop < this.prevScrollTop && !this._isNearBottom(scrollTop)) {
      this._enablePeek();
    } else {
      this._disablePeek();
    }

    this._trackPeekPos(scrollTop);
  },

  _hackyCleanupTopTopAnim: function() {
    this.$mainHeader.css({ transition: '' });
  },

  _hackyDisableTopAnim: function() {
    this.$mainHeader.css({ top: -this.$mainHeader.outerHeight() });
    this.$mainHeader.addClass(this.scrolledClass);
    setTimeout(function() {
      this.$mainHeader.css({ top: '', transition: this.topTransitionRule });
    }.bind(this), 50);
  },

  _trackPeekPos: function(scrollTop) {
    if (Math.abs(this.prevScrollTop - scrollTop) >= 150) {
      this.prevScrollTop = scrollTop;
    };
  },

  _disablePeek: function(fullDisable) {
    if (this.$mainHeader.hasClass(this.peekClass)) {
      this.$mainHeader.removeClass(this.peekClass);
      this.isPeekActive = false;
      this._updateDependants();
    }
    if (fullDisable) {
      this._hackyCleanupTopTopAnim();
      this._mainHeaderPlaceholder(false);
      this.$mainHeader.removeClass(this.scrolledClass);
    }
  },

  _enablePeek: function() {
    if (!this.$mainHeader.hasClass(this.peekClass)) {
      this.$mainHeader.addClass(this.peekClass);
      this.isPeekActive = true;
      this._updateDependants();
    }
  },

  // Specific Fae JS components need knowledge of the peek nav's presence, but aren't able to poll for this
  // data within their scroll events. The sticky table headers (_tables.js) is one such example.
  _updateDependants: function() {
    Fae.tables.sizeFixedHeader();
  },

  _mainHeaderPlaceholder: function(enable) {
    this.$mainContent.css({ paddingTop: enable ? this.$mainHeader.outerHeight() : 0 })
  },

  _isNearBottom: function(scrollTop) {
    const pageHeight = $(document).height();
    const windowHeight = $(window).height();
    const nearThreshold = 100;

    let isNear = false;
    if (scrollTop >= (pageHeight - windowHeight - nearThreshold)) {
      isNear = true;
    }

    return isNear
  },
}
