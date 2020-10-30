

function initDynamicNav(currentStep, firstStep, lastStep, progressMap, shouldSkipStep) {
  window._dynNav = {};
  window._dynNav.currentStep = currentStep;
  window._dynNav.firstStep = firstStep;
  window._dynNav.lastStep = lastStep;
  window._dynNav.progressMap = progressMap;
  window._dynNav.shouldSkipStep = shouldSkipStep;
  
  updateProgressBar = function() {
    var newPercent =  window._dynNav.progressMap[window._dynNav.currentStep] + "%"
    $("#dynamic-progress-bar .filler").css("width", newPercent);
    $("#dynamic-progress-bar .content").text(newPercent);      
  }
  
  currentStepValid = function() {
    var isValid = true;
    
    // Force validations to run
    $("#step-" + window._dynNav.currentStep + " [data-client-validation-required]").each(function() {
      var errorMessage = $(this).data("client-validation-required")
      var fn = validateField.bind(this)
      fn(errorMessage)
    })
    
    $("#step-" + window._dynNav.currentStep + " [data-client-validation-require-accept]").each(function() {
      var errorMessage = $(this).data("client-validation-require-accept");
      var fn = validateBooleanField.bind(this)
      fn(errorMessage)
    })

    $("#step-" + window._dynNav.currentStep + " .block-selector__checkbox-field input[data-client-validation-required]").each(function() {
      var errorMessage = $(this).data("client-validation-required");
      var fn = validateYesNoCheckbox.bind(this)
      fn(errorMessage)
    })
    
    $("#step-" + window._dynNav.currentStep + " .error").each(function() {
      if ($(this).text().trim() != '') {
        //console.log($(this).parent());
        isValid = false;
      }
    });
    return isValid;
  }
  
  renderCurrentStep = function() {
    window.scrollTo(0,0);
    $('.dynamic-step').hide();
    $(".back").show();
    $(".next").show();
    $(".next--link").hide();
    $(".back--link").hide();
    $("#step-" + window._dynNav.currentStep).show();
    if (window._dynNav.currentStep == window._dynNav.firstStep) {
      $(".back").hide();
      $(".back--link").show();
    }
    if (window._dynNav.currentStep == window._dynNav.lastStep) {
      $(".next").hide();
      $(".next--link").show();        
    }
    updateProgressBar();
  }
  
  changeStep = function(e, direction) {
    if (e) {
      e.preventDefault()
    };
    if (currentStepValid() || direction < 0) {
      window._dynNav.currentStep = window._dynNav.currentStep + direction;
      while (window._dynNav.shouldSkipStep(window._dynNav.currentStep)) {
        window._dynNav.currentStep += direction;
      }
      window.location.hash = '#' + window._dynNav.currentStep;
      if (window.ga) {
        ga(function() {
          var trackers = ga.getAll();
          var tracker = trackers[0];
          if (tracker) {
            tracker.set('page',  window.location.pathname + '/part-' + window._dynNav.currentStep)
            tracker.send('pageview');
          }
        });
      }
      renderCurrentStep();          
    }
    return false;      
  }
  
  setUpNav = function() {
    $(".next--virtual").click(function(e) {
      return changeStep(e, 1);
    })
    $(".back--virtual").click(function(e) {
      return changeStep(e, -1);
    })
  }
  
  jumpToFirstError = function() {
    var errors = $(".has_error")
    //console.log(errors)
    if (errors.length > 0) {
      //console.log("found error")
      var firstError = errors[0]
      var stepDiv = $(firstError).parents(".dynamic-step").get(0);
      var stepNum = parseInt(stepDiv.id.replace("step-",''));
      window._dynNav.currentStep = stepNum;
    }
  }
  
  
  
  if (window.location.hash && window.location.hash.trim() != '') {
    window._dynNav.currentStep = parseInt(window.location.hash.substr(1,window.location.hash.length-1))
  } else {
    window._dynNav.currentStep = window._dynNav.firstStep;  
    // Jump to a page that has an error?
    jumpToFirstError();
  }
  setUpNav();
  renderCurrentStep();    
}