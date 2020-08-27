function clearErrors() {
  var isGroup = false;
  var groupInputs = $(this).find("input");
  var parent = null;
  if (groupInputs.length > 0) {
    isGroup = true;
  }
  if (isGroup) {
    parent = $(this);
  } else {
    parent = $(this).parent()
  }
  var errorField = parent.siblings(".error")
  parent.removeClass('has_error') 
  errorField.html('')
}
function validateField(errorMessage) {
  var field = this;
  if (!field || !$(field).is(':visible')) {
    return;
  }
  var isGroup = false;
  var groupInputs = $(this).find("input");
  if (groupInputs.length > 0) {
    isGroup = true;
  }
  var val = ''
  var parent = null;
  if (isGroup) {
    var groupVal = null
    for(var i=0,ii=groupInputs.length;i<ii;i++) {
      var input = groupInputs[i];
      if (input.type=='radio') {
        // here we want to find if any value is present
        if ($(input).is(":checked")) {
          groupVal = '1';
          break;
        }
      } else {
        var v = $(input).val()
        // Here we want to find the shortest value and to sure all values are present
        if (groupVal == null || groupVal.length > v.length) {
          groupVal = v;
        }        
      }
    }
    val = groupVal;
    parent = $(field);
  } else {
    val = $(field).val()
    parent = $(field).parent()
  }
  var errorField = parent.siblings(".error")
  var currentError = errorField.html();
  var messageIdx = currentError.indexOf(errorMessage)
  if ((!val || val == '') && errorMessage != '') {
    // Add if not present
    if (messageIdx == -1) {
      errorField.html([currentError, errorMessage].join(" "))
    }       
    parent.addClass('has_error') 
  } else {
    if (errorMessage == '') {//Remove all
      errorField.html('')
      console.log(field, errorMessage, errorField, messageIdx)
    } else if (messageIdx >= 0) {
      currentError = currentError.split('')
      currentError.splice(messageIdx, errorMessage.length)
      errorField.html(currentError.join(''))
    } 
    //console.log(errorField.text())
    if (errorField.html().replace(/\s/g, '') == '') {
      console.log(field, errorMessage)
      
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
  //console.log(val)
  var parent = $(field).parent()
  var errorField = $(field).siblings(".error")
  var currentError = errorField.html();
  var messageIdx = currentError.indexOf(errorMessage)
  if (!val) {
    // Add if not present
    //console.log("hi", errorMessage, errorField)
    if (messageIdx == -1) {
      errorField.html([currentError, errorMessage].join(" "))
    }       
    parent.addClass('has_error') 
  } else {
    if (messageIdx >= 0) {
      currentError = currentError.split('')
      currentError.splice(messageIdx, errorMessage.length)
      errorField.html(currentError.join(''))
    } 
    //console.log(errorField.text())
    if (errorField.html().replace(/\s/g, '') == '') {
      parent.removeClass('has_error') 
    }
           
  }
}

function initValidations() {
  $("[data-client-conditional-required]").each(function() { 
    //$(this).keydown(clearErrors.bind(this));
    $(this).change(validateField.bind(this, ''));
  })
  
  $("[data-client-validation-required]").each(function() {
    var errorMessage = $(this).data("client-validation-required")
    if (this.tagName == "DIV") {
      $(this).find("input:last-child").blur(validateField.bind(this, errorMessage))
      $(this).find("input:last-child").change(validateField.bind(this, errorMessage))
      $(this).find("input:last-child").keyup(validateField.bind(this, errorMessage))    
      $(this).keydown(clearErrors.bind(this))    
    } else {
      $(this).blur(validateField.bind(this, errorMessage))
      $(this).change(validateField.bind(this, errorMessage))
      $(this).keyup(validateField.bind(this, errorMessage))    
      $(this).keydown(clearErrors.bind(this))    
    }
    
  })
  
  $("[data-client-validation-require-accept]").each(function() {
    var errorMessage = $(this).data("client-validation-require-accept");
    $(this).change(validateBooleanField.bind(this,errorMessage))
  })
  
  var fields = $("input, select, textarea, div.radio-button");
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

