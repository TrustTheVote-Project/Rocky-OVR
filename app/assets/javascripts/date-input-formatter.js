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
}