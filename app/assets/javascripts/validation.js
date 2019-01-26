function validateField(errorMessage) {
  var field = this;
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
    console.log(errorField.text())
    if (errorField.text().replace(/\s/g, '') == '') {
      parent.removeClass('has_error') 
    }
           
  }
}

function initValidations() {
  console.log('hi')
  $("[data-client-validation-required]").each(function() {
    var errorMessage = $(this).data("client-validation-required")
    $(this).blur(validateField.bind(this, errorMessage))
    $(this).change(validateField.bind(this, errorMessage))
    $(this).keyup(validateField.bind(this, errorMessage))
  })
}