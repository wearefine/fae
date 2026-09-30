/* global Fae */

/**
 * Fae form video (Mux)
 * @namespace form.video
 * @memberof form
 */
Fae.form.video = {
  pollInterval: 3000,

  init: function() {
    this.initUploaders();
    this.deleteListener();
  },

  /**
   * Set up uploaders and resume polling for processing videos. Safe to call again after AJAX'd forms load.
   */
  initUploaders: function() {
    var _this = this;

    $('.js-mux-uploader').each(function() {
      _this._initUploader(this);
    });

    $('.js-video-processing').each(function() {
      _this._pollStatus($(this).closest('.input.video'));
    });
  },

  /**
   * Point a <mux-uploader> at Fae's direct upload endpoint
   * @protected
   */
  _initUploader: function(uploader) {
    var _this = this;
    if (uploader.faeInitialized) {
      return;
    }
    uploader.faeInitialized = true;

    var $uploader = $(uploader);
    var uploadId;
    var fileName;

    uploader.endpoint = function() {
      return new Promise(function(resolve, reject) {
        $.ajax({ url: $uploader.data('endpoint'), type: 'POST', dataType: 'json' })
          .done(function(data) {
            uploadId = data.id;
            resolve(data.url);
          })
          .fail(function(xhr) {
            reject(new Error((xhr.responseJSON && xhr.responseJSON.error) || 'Unable to start upload'));
          });
      });
    };

    uploader.addEventListener('file-ready', function(e) {
      fileName = e.detail && e.detail.name;
    });

    // Only record the upload once it finishes so saving mid-upload doesn't attach a partial video
    uploader.addEventListener('success', function() {
      var $wrapper = $uploader.closest('.input.video');
      $wrapper.find('.js-mux-upload-id').val(uploadId);
      $wrapper.find('.js-mux-title').val(fileName);

      // New records can't be attached until the parent form is saved
      var attachUrl = $wrapper.attr('data-attach-url');
      if (attachUrl) {
        $.ajax({ url: attachUrl, type: 'POST', dataType: 'json', data: { upload_id: uploadId, title: fileName } })
          .done(function(data) {
            _this._renderStatus($wrapper, data);
          });
      } else {
        var $actions = $('<div class="asset-actions -video" />')
          .append($('<div class="asset-title" />').text(fileName))
          .append('<a class="asset-delete js-video-upload-delete" href="#"></a>');
        _this._renderStatus($wrapper, { html: $actions });
      }
    });
  },

  /**
   * Poll until the Mux webhook marks the video ready or errored
   * @protected
   */
  _pollStatus: function($wrapper) {
    var _this = this;
    var url = $wrapper.attr('data-status-url');
    if (!url || $wrapper.data('videoPolling')) {
      return;
    }
    $wrapper.data('videoPolling', true);

    (function poll() {
      setTimeout(function() {
        if (!$wrapper.find('.js-video-processing').length) {
          $wrapper.data('videoPolling', false);
          return;
        }

        $.ajax({ url: url, dataType: 'json', cache: false })
          .done(function(data) {
            if (data.processing) {
              poll();
            } else {
              $wrapper.data('videoPolling', false);
              _this._renderStatus($wrapper, data);
            }
          })
          .fail(function() {
            $wrapper.data('videoPolling', false);
          });
      }, _this.pollInterval);
    })();
  },

  /**
   * Swap in the server-rendered preview/processing state
   * @protected
   */
  _renderStatus: function($wrapper, data) {
    $wrapper.find('.asset-actions').remove();
    $wrapper.find('.asset-inputs').hide().before(data.html);

    if (data.processing) {
      this._pollStatus($wrapper);
    }
  },

  /**
   * Reset the input so re-saving the form doesn't reattach the deleted video
   */
  deleteListener: function() {
    var _this = this;

    $(document).on('ajax:success', '.js-video-delete', function() {
      _this._resetInput($(this).closest('.input.video'));
    });

    // Unsaved uploads are already tagged orphaned in Mux, so just clear the input
    $(document).on('click', '.js-video-upload-delete', function(e) {
      e.preventDefault();
      _this._resetInput($(this).closest('.input.video'));
    });
  },

  /**
   * @protected
   */
  _resetInput: function($wrapper) {
    $wrapper.find('.js-mux-upload-id, .js-mux-title').val('');

    // Swap in a fresh uploader; the old one is stuck in its "upload complete" state
    var $old = $wrapper.find('.js-mux-uploader');
    var $fresh = $('<mux-uploader class="js-mux-uploader"></mux-uploader>').attr('data-endpoint', $old.attr('data-endpoint'));
    $old.replaceWith($fresh);
    this._initUploader($fresh[0]);

    // Preview may have been inserted after the page's own delete handlers were bound
    $wrapper.find('.asset-actions').stop(true).remove();
    $wrapper.find('.asset-inputs').stop(true).css('opacity', '').show();
  }
};
