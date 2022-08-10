/* global Fae */

/**
 * Fae form drag n drop uploads
 * @namespace form.dragDrop
 * @memberof form
 */
Fae.form.dragDrop = {

  init: function () {
    this.dropAreaContainer = document.querySelector('.hero_image');
    this.dropArea = this.dropAreaContainer.querySelector('.asset-actions');
    this.bindListeners();
  },

  bindListeners() {
    ['dragenter', 'dragover'].forEach((eventName) => {
      this.dropArea.addEventListener(eventName, this.highlight.bind(this));
    });
    
    ['dragleave', 'drop'].forEach((eventName) => {
      this.dropArea.addEventListener(eventName, this.unhighlight.bind(this));
    });

    this.dropArea.addEventListener('drop', this.handleDrop.bind(this));
  },

  highlight(e) {
    e.preventDefault();
    this.dropAreaContainer.classList.add('highlight');
  },

  unhighlight(e) {
    e.preventDefault();
    this.dropAreaContainer.classList.remove('highlight');
  },

  handleDrop(e) {
    const fileList = e.dataTransfer.files
    const file = fileList[0]
    this.attachFile(fileList)
    this.updateInputWithFileData(file)
  },
  
  attachFile(files) {
    const fileInput = this.dropAreaContainer.querySelector('input.file')
    fileInput.files = files
  },

  updateInputWithFileData(file) {
    const label = this.dropArea.querySelector('span');
    const deleteButton = this.dropArea.querySelector('.asset-delete');
    label.innerText = file.name;
    deleteButton.style.display = 'block';
  }


};
