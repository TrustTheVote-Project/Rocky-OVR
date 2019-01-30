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
    console.log(errorField.text())
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
  initCustomValidations();
}

function initCustomValidations() {
  // When name fields have content and title is blank
  $("input").blur(function() {
    var firstName = $("#registrant_first_name, #state_registrants_va_registrant_first_name, #state_registrants_pa_registrant_first_name").val()
    var lastName = $("#registrant_last_name, #state_registrants_va_registrant_last_name, #state_registrants_pa_registrant_last_name").val()
    if (firstName != '' && lastName != '') {
      var titleField = $("#registrant_name_title, #state_registrants_va_registrant_name_title, #state_registrants_pa_registrant_name_title");
      var errorMessage = $(titleField).data("client-validation-required")
      validateField.bind(titleField)(errorMessage)
    }
  })
  $("#registrant_home_address, #registrant_us_citizen, #state_registrants_va_registrant_registration_address_1, #state_registrants_va_registrant_confirm_us_citizen, #state_registrants_va_registrant_date_of_birth, #state_registrants_pa_registrant_confirm_us_citizen, #state_registrants_pa_registrant_registration_address_1").click(function() {
    var field = $('#registrant_us_citizen, #state_registrants_va_registrant_confirm_us_citizen, #state_registrants_pa_registrant_confirm_us_citizen');
    var errorMessage = $(field).data("client-validation-require-accept")
    validateBooleanField.bind(field)(errorMessage)    
  })
  $("#registrant_home_address, #state_registrants_va_registrant_registration_address_1, #state_registrants_va_registrant_date_of_birth, #state_registrants_pa_registrant_registration_address_1").focus(function() {
    var field = $('#registrant_us_citizen, #state_registrants_va_registrant_confirm_us_citizen, #state_registrants_pa_registrant_confirm_us_citizen');
    var errorMessage = $(field).data("client-validation-require-accept")
    validateBooleanField.bind(field)(errorMessage)    
  })

  $("#registrant_home_address, #registrant_us_citizen, #state_registrants_va_registrant_registration_address_1, #state_registrants_va_registrant_confirm_us_citizen, #state_registrants_va_registrant_date_of_birth, #state_registrants_va_registrant_confirm_voter_record_update, #state_registrants_pa_registrant_registration_address_1, #state_registrants_pa_registrant_confirm_will_be_18").click(function() {
    var field = $('#state_registrants_va_registrant_confirm_voter_record_update, #state_registrants_pa_registrant_confirm_will_be_18');
    var errorMessage = $(field).data("client-validation-require-accept")
    validateBooleanField.bind(field)(errorMessage)    
  })
  
  $("#registrant_home_address, #state_registrants_va_registrant_registration_address_1, #state_registrants_va_registrant_date_of_birth, #state_registrants_pa_registrant_registration_address_1").focus(function() {
    var field = $('#state_registrants_va_registrant_confirm_voter_record_update, #state_registrants_pa_registrant_confirm_will_be_18');
    var errorMessage = $(field).data("client-validation-require-accept")
    validateBooleanField.bind(field)(errorMessage)    
  })
  
  
  
  // $("#registrant_home_address, #registrant_will_be_18_by_election").click(function() {
  //   var citizenField = $('#registrant_will_be_18_by_election').get(0);
  //   var errorMessage = $("#registrant_will_be_18_by_election").data("client-validation-require-accept")
  //   validateBooleanField.bind(citizenField)(errorMessage)
  // })
  
}