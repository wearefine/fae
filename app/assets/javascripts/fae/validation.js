var Validator = {

  init: function () {
    this.validate();
    this.formValidate();
  },

  vars: {
    IS_VALID: '',
    chosen_select: '.chosen-container .chosen-search input'
  },

  formValidate: function () {
    this.attemptSubmit();
  },

  validate: function () {
    var that = this;
    $('[data-validate]').each(function () {
      var $validationInput = $(this);
      var originalValue = $validationInput.val();
      if ($validationInput.data('validate').length) {
        if ($validationInput.siblings('.chosen-container').length) {
          $validationInput = that.isChosen($validationInput);
          $('body').on('propertychange change click keyup input paste', that.vars.chosen_select, function () {
            var $chosenInput = $(this);
            if (originalValue !== $(this).val()) { that.judgeIt($chosenInput); }
          });
        } else {
          $validationInput.on('propertychange change click keyup input paste', function () {
            var $input = $(this);
            if (originalValue !== $(this).val()) { that.judgeIt($input); }
          });
        }
      }
    });
  },

 //  $('.myElements').each(function () {
 //   var elem = $(this);

 //   // Save current value of element
 //   elem.data('oldVal', elem.val());

 //   // Look for changes in the value
 //   elem.bind("propertychange change click keyup input paste", function (event){
 //      // If value has changed...
 //      if (elem.data('oldVal') != elem.val()) {
 //       // Updated stored value
 //       elem.data('oldVal', elem.val());

 //       // Do action
 //       ....
 //     }
 //   });
 // });

  // private functions

  attemptSubmit: function () {
    var that = this;
    $('form').on('submit', function (e) {
      that.vars.IS_VALID = true;
      $('[data-validate]').each(function () {
        var $validationInput = $(this);
        if ($validationInput.data('validate').length) {
          that.judgeIt($validationInput);
        }
      });
      if (that.vars.IS_VALID === false) {
        e.preventDefault();
      }
    });
  },

  judgeIt: function ($input) {
    var that = this;
    judge.validate($input[0], {
      valid: function () {
        that.createSuccessClass($input);
      },
      invalid: function (input, messages) {
        that.vars.IS_VALID = false;
        that.labelNameInMessage($input, messages);
        that.createOrReplaceError($input, messages);
      }
    });
  },

  isChosen: function (input) {
    var that = this;
    input.siblings(that.vars.chosen_select);
  },

  createSuccessClass: function ($input) {
    $input.addClass('valid').removeClass('invalid');
    $input.parent().removeClass('field_with_errors').children('.error').remove();
  },

  labelNameInMessage: function (elm, messages) {
    var i, siblings, index;
    for (i = messages.length - 1; i >= 0; i--) {
      siblings = elm.siblings('label');
      if (siblings.get(0).childNodes[0].nodeName === "ABBR") { index = 1;}
      index = index || 0;
      messages[i] = siblings.get(0).childNodes[index].nodeValue + " " + messages[i];
    }
  },

  createOrReplaceError: function ($input, messages) {
    $input.addClass('invalid').removeClass('valid');
    if ($input.parent('.input').children('.error').length) {
      $input.parent('.input').children('.error').text(messages.join(','));
    } else {
      $input.parent('.input').addClass('field_with_errors').append("<span class='error'>" + messages.join(',') + "</span>");
    }
  }


};