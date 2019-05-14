var formatPartialDateInput = function(el, event) {
  //console.log(el, event);
  if (event.type=='propertychange' && event.originalEvent.propertyName != 'value') {
    return
  }
  // if (event.key.length > 1 || el != event.originalEvent.target) {
  //   return;
  // }
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
    $(el).next("input").focus();
  }
  if (!isYear && input.length > 2) {
    input = input.substr(0,2)
  } else if (isYear && input.length > 4) {
    input = input.substr(0,4)
  }
  $(el).val(input)
}

var formatDateInputs = function() {
  $("[placeholder=MM], [placeholder=DD], [placeholder=YYYY]").each(function() {
    $(this).on('input propertychange', function(e) { formatPartialDateInput(this, e)} )
  })
}