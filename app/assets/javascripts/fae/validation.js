var Validator = {

  init: function() {
    this.validate();
    this.formValidate();
  },

  vars: {
    chosen_select: '.chosen-container .chosen-search input'
  },

  formValidate: function() {
    var isValid;
    $('form input[type=submit]').on('click',function(e) {
      e.preventDefault();
      isValid = true;

      $('[data-validate]').each(function(i) {
        $obj = $(this);
        if ($obj.data('validate').length) {
          $elm = $obj;
          judge.validate($elm[0], {
            valid: function() {
              Validator.createSuccessClass($elm);
            },
            invalid: function(input, messages) {
              isValid = false;
              Validator.labelNameInMessage($elm, messages);
              Validator.createOrReplaceError($elm, messages);
            }
          });
        }
      });
      if (isValid) { $('form').submit() };
    });

  },

  validate: function(){
    $('[data-validate]').each(function(i) {
      var validationInput = $(this);
      if ( validationInput.data('validate').length ) {
        if( validationInput.siblings('.chosen-container').length ) {
          validationInput = Validator.isChosen(validationInput);
          $('body').on('blur', Validator.vars.chosen_select, function() {
            var $chosenInput = $(this);
            Validator.judge( $chosenInput );
          });
        } else {
          validationInput.on('blur', function(){
            $input = $(this);
            Validator.judge( $input );
          });
        }
      }
    });
  },

  // private functions

  judge: function($input) {
    judge.validate($input[0], {
      valid: function() {
        Validator.createSuccessClass($input);
      },
      invalid: function(input, messages) {
        Validator.labelNameInMessage($input, messages);
        Validator.createOrReplaceError($input, messages);
      }
    });
  },

  isChosen: function(input) {
    input.siblings( Validator.vars.chosen_select );
  },

  createSuccessClass: function($input) {
    $input.addClass('valid').removeClass('invalid');
    $input.parent().removeClass('field_with_errors').children('.error').remove();
  },

  labelNameInMessage: function(elm, messages){
    for (var i = messages.length - 1; i >= 0; i--) {
      var siblings = elm.siblings('label');
      if (siblings.get(0).childNodes[0].nodeName == "ABBR") {var index = 1};
      var index = index || 0;
      messages[i] = siblings.get(0).childNodes[index].nodeValue + " " + messages[i];
    };
  },

  createOrReplaceError: function($input, messages) {
    $input.addClass('invalid').removeClass('valid');
    if ($input.parent('.input').children('.error').length) {
      $input.parent('.input').children('.error').text(messages.join(','));
    } else {
      $input.parent('.input').addClass('field_with_errors').append("<span class='error'>"+messages.join(',')+"</span>");
    };
  }


}