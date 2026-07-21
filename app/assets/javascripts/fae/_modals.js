/* global Fae, modal, FCH */

/**
 * Fae modals
 * @namespace
 */
Fae.modals = {
  ready: function() {
    this.$body = $('body');
    this.openClass = 'modal-open';
    this.modalClass = 'MODAL_ID-modal-open';
    this.showEvent = 'modal:show';
    this.shownEvent = 'modal:shown';
    this.closeEvent = 'modal:close';
    this.closedEvent = 'modal:closed';
    this.modalOpen = false;

    this.imageModals();
    this.markdownModalListener();

    this.ajaxModalListener();
  },

  /**
   * Click event to open modal with only an image
   */
  imageModals: function() {
    $('#js-main-content').on('click', '.js-image-modal', function(e) {
      e.preventDefault();
      var $this = $(this);
      var image = new Image();

      function openImageModal(width, height) {
        var modalPadding = 55;
        var viewportMargin = 60;
        var maxModalWidth = Math.max(FCH.$window.width() - viewportMargin, 220);
        var maxModalHeight = Math.max(FCH.$window.height() - viewportMargin, 220);
        var imageWidth = width || 1;
        var imageHeight = height || 1;
        var availableWidth = maxModalWidth - modalPadding;
        var availableHeight = maxModalHeight - modalPadding;
        var widthRatio = availableWidth / imageWidth;
        var heightRatio = availableHeight / imageHeight;
        var scale = Math.min(widthRatio, heightRatio, 1);
        var modalWidth = Math.max(Math.round((imageWidth * scale) + modalPadding), 220);
        var modalHeight = Math.max(Math.round((imageHeight * scale) + modalPadding), 220);

        $this.modal({
          minHeight: modalHeight,
          minWidth: modalWidth,
          maxHeight: maxModalHeight,
          maxWidth: maxModalWidth,
          overlayClose: true,
          containerCss: { overflow: 'hidden' }
        });
      }

      // Wait for natural dimensions so large images can be constrained to the viewport.
      image.onload = function() {
        openImageModal(image.naturalWidth || image.width, image.naturalHeight || image.height);
      };

      image.onerror = function() {
        openImageModal($this.width(), $this.height());
      };

      image.src = $this.attr('src');

      if (image.complete) {
        image.onload();
      }
    });
  },

  /**
   * Display markdown guide in a modal
   * @see {@link form.text.overrideMarkdownDefaults}
   * @see {@link modals.markdownModalListener}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  markdownModal: function() {
    var markdown_hint_width = $('.markdown-hint').width() + 40;

    $('.markdown-hint-wrapper').modal({
      minHeight: 430,
      minWidth: markdown_hint_width,
      overlayClose: true,
      zIndex: 1100
    });
  },

  /**
   * Markdown guide shown on document click of "markdown-support" so as to support AJAX'd markdown-support fields.
   * @fires {@link modals.markdownModal}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  markdownModalListener: function() {
    FCH.$document.on('click', '.markdown-support', this.markdownModal);
  },

  /**
   * load remote data, open modal view
   * @see {@link modals.formModalListener}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  openAjaxModal: function (remoteUrl, relatedTarget) {
    var _this = this;

    $.get(remoteUrl, function (data) {
      //Open remote url content in modal window
      $(data).modal({
        minHeight: "75%",
        minWidth: "75%",
        overlayClose: true,
        zIndex: 1100,
        containerId: "fae-modal",
        persist: true,
        opacity: 70,
        overlayCss: { backgroundColor: "#000" },
        onOpen: function (dialog) {
          // Fade in modal + show data
          dialog.overlay.fadeIn();
          dialog.container.fadeIn(function() {
            var shownEvent = $.Event(_this.shownEvent, { dialog: dialog, relatedTarget: relatedTarget });
            _this.$body.trigger(shownEvent);
          });
          dialog.data.show();

          var modalClasses = [_this.createClassFromModalId(relatedTarget.attr('id')), _this.openClass].join(' ');

          _this.modalOpen = true;
          _this.$body.addClass(modalClasses);
        },
        onShow: function (dialog) {
          var showEvent = $.Event(_this.showEvent, { dialog: dialog, relatedTarget: relatedTarget });
          _this.$body.trigger(showEvent);

          $(dialog.container).css('height', 'auto')
        },
        onClose: function (dialog) {
          var closeEvent = $.Event(_this.closeEvent, { dialog: dialog, relatedTarget: relatedTarget });
          _this.$body.trigger(closeEvent);

          // Fade out modal and close
          dialog.container.fadeOut();
          dialog.overlay.fadeOut(function () {
            $.modal.close(); // must call this!

            var closedEvent = $.Event(_this.closedEvent, { dialog: dialog, relatedTarget: relatedTarget });
            var modalClasses = [_this.createClassFromModalId(relatedTarget.attr('id')), _this.openClass].join(' ');

            _this.modalOpen = false;
            _this.$body.removeClass(modalClasses);
            _this.$body.trigger(closedEvent);
          });
        }
      });

    });
  },

  /**
   * Click event listener for ajax modal links triggering specific view within modal popup
   * @fires {@link modals.ajaxModal}
   * @has_test {features/form_helpers/fae_input_spec.rb}
   */
  ajaxModalListener: function () {
    var _this = this;

    FCH.$document.on('click', '.js-fae-modal', function (e) {
      e.preventDefault();
      var $this = $(this);
      var url = $this.attr('href');
      var id = $this.attr('id');

      _this.openAjaxModal(url, $this)
    });
  },

  createClassFromModalId: function(modalId) {
    return this.modalClass.replace('MODAL_ID', modalId);
  }
};
