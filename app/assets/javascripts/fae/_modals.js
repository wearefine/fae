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
    this.loadDataEvent = 'modal:data_loaded';
    this.openedEvent = 'modal:opened';
    this.showEvent = 'modal:show';
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

      // create invisi-image to get natural width/height
      var image = new Image();
      image.src = $this.attr('src');
      var image_width = image.width + 55;
      var image_height = image.height + 55;

      $this.modal({
        minHeight: image_height,
        minWidth: image_width,
        overlayClose: true
      });
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
  openAjaxModal: function (remoteUrl, modalId) {
    var _this = this;

    $.get(remoteUrl, function (data) {
      var dataLoadedEvent = $.Event(_this.loadDataEvent, { html: $(data), modalId: modalId });
      _this.$body.trigger(dataLoadedEvent);

      //Open remote url content in modal window
      $(data).modal({
        minHeight: "75%",
        minWidth: "75%",
        overlayClose: true,
        zIndex: 1100,
        containerId: "fae-ajax-modal",
        persist: true,
        opacity: 70,
        overlayCss: { backgroundColor: "#000" },
        onOpen: function (dialog) {
          // Fade in modal + show data
          dialog.overlay.fadeIn();
          dialog.container.fadeIn();
          dialog.data.show();

          var modalClasses = [_this._createClassFromModalId(modalId), _this.openClass].join(' ');
          var openEvent = $.Event(_this.openedEvent, { dialog: dialog, modalId: modalId });

          _this.modalOpen = true;
          _this.$body.addClass(modalClasses);
          _this.$body.trigger(openEvent);
        },
        onShow: function (dialog) {
          var showEvent = $.Event(_this.showEvent, { dialog: dialog, modalId: modalId });
          _this.$body.trigger(showEvent);
        },
        onClose: function (dialog) {
          // Fade out modal and close
          dialog.container.fadeOut();
          dialog.overlay.fadeOut(function () {
            $.modal.close(); // must call this!

            var closeEvent = $.Event(_this.closedEvent, { dialog: dialog, modalId: modalId });
            var modalClasses = [_this._createClassFromModalId(modalId), _this.openClass].join(' ');

            _this.modalOpen = false;
            _this.$body.removeClass(modalClasses);
            _this.$body.trigger(closeEvent);
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

    FCH.$document.on('click', '.js-ajax-modal', function (e) {
      e.preventDefault();
      var $this = $(this);
      var target = $this.attr('href');
      var id = $this.attr('id');

      _this.openAjaxModal(target, id)
    });
  },

  _createClassFromModalId(modalId) {
    return this.modalClass.replace('MODAL_ID', modalId);
  }
};
