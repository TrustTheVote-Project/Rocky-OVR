var formatPartialDateInput = function(el, event) {
  console.log(el, event);
  if (event.key.length > 1 || el != event.target) {
    return;
  }
  
  var val = ($(el).val());
  var isMonth = $(el).attr('placeholder')=="MM";
  var isDay = $(el).attr('placeholder')=="DD";
  var isYear = $(el).attr('placeholder')=="YYYY";
  var input = val;
  input = input.replace(/[^\d]/g, '')
  isValid = false;
  // Determine if it's a value that must be a single digit
  if (input.length == 1 && ((isMonth && parseInt(input) > 1) || (isDay && parseInt(input) > 3))) {
    input = "0" + input;
    isValid = true;
  }
  if (input.length == 2) {
    if (isMonth && parseInt(input) > 0 && parseInt(input) <= 12) {
      isValid = true;
    }
    if (isDay && parseInt(input) > 0 && parseInt(input) <= 31) {
      isValid = true;
    }    
  }
  if (!isYear && input.length == 2 && isValid) {
    //$(el).parents(".registrant-form__date-of-birth__line").next('.registrant-form__date-of-birth__line').find("input").focus();
  }
  $(el).val(input)
}

var formatDateInput = function(el, event) {
  //console.log(el, event)
  var val = ($(el).val());
  var input = val;
  var userMovedNext = false;
  var userBackspaced = false
  input = input.replace(/\//g, '-');
  input = input.replace(/[^\d-]/g, '')
  if (event.key == "-" || event.key == "/") {
    userMovedNext = true
  }
  if (event.key.length > 1) {
    return;
  }
  inputs = input.match(/(\d+)(-)?(\d+)?(-)?(\d+)?/)
  //console.log(input, inputs);
  if (inputs) {
    var month = inputs[1] || ''
    var doneMonth = (inputs[1] && inputs[2]) || (month && month.length >= 2)
    var day = inputs[3] || ''
    var doneDay = (inputs[3] && inputs[4]) || (day && day.length >= 2)
    var year = inputs[5] || ''
  
    if (doneMonth && month && month.length == 1) {
      month = '0'+month;
    }
    if (month.length > 2) {
      day = month.substr(2,month.length) + day;
      month = month.substr(0,2)
    }    
    //console.log(month, day)
    
    
    if (doneDay && day && day.length == 1) {
      day = '0'+day;
    }

    input = month;
    if (doneMonth) {
      input += "-" + day 
    }
    
    if (doneDay) {
      input += "-" + year;
    }
  }
  if (userBackspaced & input.endsWith('-') & !val.endsWith('-')) {
    input = input.substr(0, input.length-1)
  }
  $(el).val(input)
  //DD-DD-DDDD
}

var formatDateInputs = function() {
  $("[placeholder=MM-DD-YYYY]").each(function() {
    $(this).keyup(function(e) { formatDateInput(this, e)} )
  })
  $("[placeholder=MM], [placeholder=DD], [placeholder=YYYY]").each(function() {
    $(this).keyup(function(e) { formatPartialDateInput(this, e)} )
  })
}