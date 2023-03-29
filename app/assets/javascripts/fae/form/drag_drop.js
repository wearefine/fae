/* global Fae */

/**
 * Fae form drag n drop uploads
 * @namespace form.dragDrop
 * @memberof form
 */
Fae.form.dragDrop = {

  init: function () {
    this.fileInputs = document.querySelectorAll('input[type="file"]');
    if (this.fileInputs.length === 0) return;

    this.bindListeners();
  },

  bindListeners() {

    Array.from(this.fileInputs).forEach(input => {
      const container = input.closest('.input.field');

      ['dragenter', 'dragover'].forEach((eventName) => {
        container.addEventListener(eventName, this.highlight.bind(container));
      });

      ['dragleave', 'drop'].forEach((eventName) => {
        container.addEventListener(eventName, this.unhighlight.bind(container));
      });

      // This needed to be bound via jquery since tests have to use a simulated jquery event and native event listeners do not pickup on jquery events
      $(container).on('drop', this.handleDrop.bind(this, container));
    })
  },

  highlight(e) {
    e.stopPropagation();
    e.preventDefault();
    this.classList.add('highlight');
  },

  unhighlight(e) {
    e.stopPropagation();
    e.preventDefault();
    this.classList.remove('highlight');
  },

  handleDrop(inputContainer, e) {
    // return the original event from the jquery event
    if (e.originalEvent) {
      e = e.originalEvent;
    }
    const input = inputContainer.querySelector('input[type="file"]');
    const fileList = e.dataTransfer.files;
    const file = fileList[0];
    const isValidFile = this.validatesFileSize(input, file);

    if (isValidFile) {
      this.attachFile(input, fileList);
      this.addFileInfo(inputContainer, file);
    }
  },
  
  attachFile(input, files) {
    input.files = files;
  },

  addFileInfo(inputContainer, file) {
    const deleteButton = inputContainer.querySelector('.asset-delete');

    // only exists if image is already loaded into field
    let label = inputContainer.querySelector('.asset-title');
    if (!label) {
      // else is a new image
      label = inputContainer.querySelector('.asset-actions span');
    }
    label.innerText = file.name;
    deleteButton.style.display = 'block';
  },

  validatesFileSize(input, file) {
    const limit = parseInt(input.dataset.limit);
    const fileSize = file.size / 1024 / 1024;

    if (fileSize < limit) {
      this.removeFileSizeError(input);
      return true;
    }

    this.addFileSizeError(input, limit);
    return false;
  },

  addFileSizeError(input, limit) {
    const errorElem = document.createElement('span');
    errorElem.innerText = input.dataset.exceeded.replace('###', limit);
    errorElem.classList.add('error');
    input.after(errorElem);
    input.parentElement.classList.add('field_with_errors');
  },

  removeFileSizeError(input) {
    const nextSibling = input.nextSibling;
    if (nextSibling.classList.contains('error')) {
      nextSibling.remove();
    }
    input.parentElement.classList.remove('field_with_errors');
  }

};
