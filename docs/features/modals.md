# Modals
You can use the Fae modal feature to add the ability of opening a specific view (list view or nested form) within a modal popup. You can then use the custom event hooks to extend the modal functionality.

* [Usage](#usage)
* [Callbacks](#callbacks)

---

## Usage
The most basic way to setup a modal popup is to attach the specific class to a link that references a specific view/url. This will add a click event listener and when clicked will use an ajax request to return the view/url data and trigger the modal. When the modal is opened it will also add `.modal-open` and `.{link_id}-modal-open` classes to the `body`.

### Via Modal Link

You can activate a modal by adding the `.js-fae-modal` class on a link as well as passing in view path/url as href to trigger ajax modal on click.

```slim
  <a href="/admin/cats/new" id="cats" class="js-fae-modal">add new cat via modal popup</a>
```

### Via Javascript
Open a modal using JS by passing a remote url to `openAjaxModal` function.

```javascript
  Fae.modals.openAjaxModal(remoteUrl);
```

### Close Modal
You can programatically close the currently opened modal popup by calling `$.modal.close();`

**Example**
```javascript
  $("body").on("modal:show", function (e) {
    $('#fae-modal').on('ajax:success', function (evt, data, status, xhr) {
      if (Fae.modals.modalOpen) {
        $.modal.close();
      }
    });
  }
```

## Events/Callbacks

These events can be used to hook into the modal functionality. The modal object is available by referencing the `dialog` property. If modal is triggered by a click, the clicked element will be available as the `relatedTarget` event property.

| event | description |
|--------|-------------------|
| modal:show |  This event is useful for binding events/actions after modal dialog elements have been initialized.  |


```javascript
  $("body").on("modal:show", function (e) {
    //do something once modal show is triggered

    if (e.dialog.data[0].classList.contains('nested-form')) {
      Fae.form.ajax.htmlListeners();
    }
  }
```

| event | description |
|--------|-------------------|
| modal:shown |  This event is triggered once modal is completely visible and fadeIn animation has completed.  |

```javascript
  $("body").on("modal:shown", function (e) {
    //do something once modal is fully visible
  }
```

| event | description |
|--------|-------------------|
| modal:close |  This event is triggered immediately when the onClose function has been triggered.  |

```javascript
  $("body").on("modal:close", function (e) {
    //do something once modal close is triggered
  }
```

| event | description |
|--------|-------------------|
| modal:closed |  This event is triggered once modal is completely hidden and fadeOut animation has completed.  |

```javascript
  $("body").on("modal:closed", function (e) {
    //do something once modal is fully hidden
  }
```
