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
    this.unavailableListener();
    this.dropListener();
  },

  /**
   * Accept files dropped anywhere on the field, highlighted the same way as image and file inputs (see form.dragDrop).
   * The uploader's own drop zone is turned off with no-drop so the field can match those inputs.
   */
  dropListener: function() {
    if (this.dropListenerBound) {
      return;
    }
    this.dropListenerBound = true;
    var _this = this;

    // Delegated so fields in AJAX'd forms work too
    $(document).on('dragenter dragover', '.input.video', function(e) {
      e.preventDefault();
      e.stopPropagation();
      if (_this._dropTarget($(this))) {
        this.classList.add('highlight');
      }
    });

    $(document).on('dragleave', '.input.video', function(e) {
      e.preventDefault();
      e.stopPropagation();
      this.classList.remove('highlight');
    });

    $(document).on('drop', '.input.video', function(e) {
      // Always prevent the default so a missed drop doesn't make the browser navigate to the file
      e.preventDefault();
      e.stopPropagation();
      this.classList.remove('highlight');

      var uploader = _this._dropTarget($(this));
      var dataTransfer = e.originalEvent && e.originalEvent.dataTransfer;
      var file = dataTransfer && dataTransfer.files[0];
      if (!uploader || !file) {
        return;
      }

      // Matches the accept list on the uploader's own file picker
      if (!/^(video|audio)\//.test(file.type)) {
        _this._dropError($(this), $(uploader).attr('data-invalid-type'));
        return;
      }
      _this._dropError($(this), null);

      // Same event <mux-uploader-drop> dispatches, so the upload runs exactly as if the file were picked
      uploader.dispatchEvent(new CustomEvent('file-ready', { composed: true, bubbles: true, detail: file }));
    });
  },

  /**
   * Show (or, with no message, clear) a drop error, styled like the image input's file size error
   * @protected
   */
  _dropError: function($wrapper, message) {
    var $inputs = $wrapper.find('.asset-inputs');
    $inputs.find('.js-video-drop-error').remove();
    // .field_with_errors is what styles .error (server validation errors set it on the outer field instead)
    $inputs.toggleClass('field_with_errors', !!message);
    if (message) {
      $('<span class="error js-video-drop-error" />').text(message).prependTo($inputs);
    }
  },

  /**
   * The field's uploader, if it's showing and hasn't started on a file yet
   * @protected
   */
  _dropTarget: function($wrapper) {
    var $inputs = $wrapper.find('.asset-inputs');
    var uploader = $inputs.find('.js-mux-uploader')[0];
    if (!uploader || !$inputs.is(':visible') || uploader.faeFileChosen) {
      return null;
    }
    return uploader;
  },

  /**
   * Swap a broken thumbnail for a message. The asset may have been deleted in the Mux environment that owns it,
   * e.g. on prod after its row was pulled down to dev.
   */
  unavailableListener: function() {
    if (this.unavailableListenerBound) {
      return;
    }
    this.unavailableListenerBound = true;

    // error events don't bubble, so listen in the capture phase to catch thumbnails added after page load
    document.addEventListener('error', function(e) {
      var $img = $(e.target);
      if (!$img.is('img.js-video-modal')) {
        return;
      }
      $img.closest('.asset-actions').find('.asset-title').text($img.attr('data-unavailable'));
      $img.remove();
    }, true);
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
    // Saved before any upload so _resetInput can rebuild it without state attributes like file-ready
    uploader.faeTemplate = uploader.faeTemplate || uploader.outerHTML;

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
      uploader.faeFileChosen = true;
      _this._dropError($uploader.closest('.input.video'), null);
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
    // children(), not find(): the uploader's file chooser is also an .asset-actions and must stay
    $wrapper.children('.asset-actions').remove();
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

    // Swap in a fresh uploader; the old one is stuck in its "upload complete" state.
    // Rebuilt from its original markup to keep no-drop, the endpoint and the slotted file chooser.
    var $old = $wrapper.find('.js-mux-uploader');
    var $fresh = $($old[0].faeTemplate);
    $fresh[0].faeTemplate = $old[0].faeTemplate;
    $old.replaceWith($fresh);
    this._initUploader($fresh[0]);
    this._dropError($wrapper, null);

    // Preview may have been inserted after the page's own delete handlers were bound
    $wrapper.children('.asset-actions').stop(true).remove();
    $wrapper.find('.asset-inputs').stop(true).css('opacity', '').show();
  }
};