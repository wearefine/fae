var Validator = {

  init: function() {
    this.validate();
  },


  validate: function(){
    $('[data-validate]').each(function(i) {
      $obj = $(this);
      if ($obj.data('validate').length) {
        if($obj.siblings('.chosen-container').length) {
          $obj = $obj.siblings('.chosen-container');
        }
        $obj.on('focusout select', function(){
          $elm = $(this);
          judge.validate($elm[0], {
            valid: function(element) {
              Validator.createSuccessClass(element, $elm);
            },
            invalid: function(element, messages) {
              Validator.labelNameInMessage($elm, messages);
              Validator.createOrReplaceError(element, $elm, messages);
            }
          });
        })
      }
    });
  },

  createSuccessClass: function(elm, input) {
    $(elm).addClass('valid').removeClass('invalid');
    input.parent().removeClass('field_with_errors').children('.error').remove();
  },

  labelNameInMessage: function(elm, messages){
    for (var i = messages.length - 1; i >= 0; i--) {
      var siblings = elm.siblings('label');
      console.log(siblings);
      if (siblings.get(0).childNodes[0].nodeName == "ABBR") {var index = 1};
      var index = index || 0;
      messages[i] = siblings.get(0).childNodes[index].nodeValue + " " + messages[i];
    };
  },

  createOrReplaceError: function(elm, input, messages) {
    $(elm).addClass('invalid').removeClass('valid');
    if (input.siblings('.error').length) {
      input.siblings('.error').text(messages.join(','));
    } else {
      input.parent().addClass('field_with_errors').append("<span class='error'>"+messages.join(',')+"</span>");
    };
  }


}