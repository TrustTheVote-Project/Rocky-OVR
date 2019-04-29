function validateField(errorMessage) {
  var field = this;
  if (!field) {
    return;
  }
  var val = $(field).val()
  var parent = $(field).parent()
  var errorField = parent.siblings(".error")
  var currentError = errorField.text();
  var messageIdx = currentError.indexOf(errorMessage)
  if (!val || val == '') {
    // Add if not present
    if (messageIdx == -1) {
      errorField.text([currentError, errorMessage].join(" "))
    }       
    parent.addClass('has_error') 
  } else {
    if (messageIdx >= 0) {
      currentError = currentError.split('')
      currentError.splice(messageIdx, errorMessage.length)
      errorField.text(currentError.join(''))
    } 
    //console.log(errorField.text())
    if (errorField.text().replace(/\s/g, '') == '') {
      parent.removeClass('has_error') 
    }
           
  }
}

function validateBooleanField(errorMessage) {
  var field = this;
  if (!field) {
    return
  }
  var val = $(field).is(":checked")
  console.log(val)
  var parent = $(field).parent()
  var errorField = $(field).siblings(".error")
  var currentError = errorField.text();
  var messageIdx = currentError.indexOf(errorMessage)
  if (!val) {
    // Add if not present
    console.log("hi", errorMessage, errorField)
    if (messageIdx == -1) {
      errorField.text([currentError, errorMessage].join(" "))
    }       
    parent.addClass('has_error') 
  } else {
    if (messageIdx >= 0) {
      currentError = currentError.split('')
      currentError.splice(messageIdx, errorMessage.length)
      errorField.text(currentError.join(''))
    } 
    console.log(errorField.text())
    if (errorField.text().replace(/\s/g, '') == '') {
      parent.removeClass('has_error') 
    }
           
  }
}

function initValidations() {
  $("[data-client-validation-required]").each(function() {
    var errorMessage = $(this).data("client-validation-required")
    $(this).blur(validateField.bind(this, errorMessage))
    $(this).change(validateField.bind(this, errorMessage))
    $(this).keyup(validateField.bind(this, errorMessage))
  })
  
  $("[data-client-validation-require-accept]").each(function() {
    var errorMessage = $(this).data("client-validation-require-accept");
    $(this).change(validateBooleanField.bind(this,errorMessage))
  })
  
  var fields = $("input, select, textarea");
  var validatePrevious = function(element) {
    for (var i=0,ii=fields.length;i<ii;i++) {
      var field = fields[i]
      if (field == element) {
        break;
      } else {
        var errorMessage = $(field).data("client-validation-required")  
        if (errorMessage && !errorMessage == '') {
          validateField.bind(field)(errorMessage);
        }      
        errorMessage = $(field).data("client-validation-require-accept")
        if (errorMessage && !errorMessage == '') {
          validateBooleanField.bind(field)(errorMessage)    
        }      
      }
    }
  }
  fields.click(function() { validatePrevious(this) });
  fields.focus(function() { validatePrevious(this) });  
}

