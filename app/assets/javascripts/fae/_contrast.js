/* global Fae, modal, FCH */

/**
 * Fae contrast
 * @namespace
 */

Fae.contrast = {
  ready: function () {
    this.highlightHex = getComputedStyle(document.body).getPropertyValue('--highlight-color');

    // exit if highlight color css var not found
    if (!this.highlightHex) {
      return;
    }
    
    this.$body        = $('body');
    this.whiteHex     = '#fff';
    this.blackHex     = '#000';
    this.hexRegex     = /(^#[0-9a-fA-F]{6}$)/;

    // exit if highlight color is not a valid hex color
    if (!this.hexRegex.test(this.highlightHex)) {
      return;
    }

    this.setForegroundColor();
  },
  

  // dynamically set foreground color based on contrast with user set highlight color
  setForegroundColor() {
    const yiq = this.getContrastYIQ();
    if (yiq >= 170) {
      this.$body[0].style.setProperty('--foreground-color', this.blackHex);
    } else {
      this.$body[0].style.setProperty('--foreground-color', this.whiteHex);
    }
  },

  getContrastYIQ() {
    const hex = this.highlightHex.replace('#', '');
    const r = parseInt(hex.substr(0, 2), 16);
    const g = parseInt(hex.substr(2, 2), 16);
    const b = parseInt(hex.substr(4, 2), 16);
    return ((r * 299) + (g * 587) + (b * 114)) / 1000;
  }


};
