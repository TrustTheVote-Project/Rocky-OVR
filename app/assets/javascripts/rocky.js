function registerTouch() {};

function isFacebookApp() {
  var ua = navigator.userAgent || navigator.vendor || window.opera;
  ua = ua.toLowerCase();
  return ((ua.indexOf("fban") > -1) || (ua.indexOf("fbav") > -1) || (ua.indexOf("instagram") > -1));
}


function hideErrors() {
  $('.error').each(function(){ $(this).css('opacity', 0); });
};

function revealErrors() {
  $('.error').each(function() { $(this).animate({opacity: 1}); });
};

function toggleFieldSet(checkbox, set, rule, speed, hideOnCheck) {
  var show = hideOnCheck ? !$(checkbox).is(':checked') : $(checkbox).is(':checked')
	if (show) {
    $(rule).hide(0);
    $(set).fadeIn(speed);
  } else {
    $(set).fadeOut(speed);
    $(set).find(".has_error input, .has_error select").each(function() {
      console.log(this);
      clearErrors.bind(this)();
    })
    $(rule).show(0);
  }
};

function checkboxTogglesSet(checkbox, set, rule, hideOnCheck) {
  hideOnCheck = hideOnCheck || false;
  toggleFieldSet(checkbox, set, rule, 0, hideOnCheck);
  $(checkbox).change(function () {
    toggleFieldSet(checkbox, set, rule, 'fast', hideOnCheck);
  });
};

function addTooltips(selector, target_corner, tooltip_corner) {
  $(selector).qtip({
		style: {
			classes: 'qtip-blue qtip-rounded'
		},
    position: {
      at: target_corner,
      my: tooltip_corner,
			viewport: $(window)
    },
    content: {
      button: true
    },
    hide: { fixed: true, delay: 300, effect: { length: 50 } }, // Hovering over tooltip keeps them visible
    show: { delay: 50, effect: { length: 50 }},
    events: {
      show: function(event, api) { 
        $(selector).addClass('tooltip-shown'); 
      },
      hide: function(event, api) { 
        $(selector).removeClass('tooltip-shown'); 
      }
    }
  }).on('touchend', function() {
    if ($(this).hasClass('tooltip-shown')) {
      $(this).qtip('hide').mouseout().blur().parent().click();      
    } else {
      $(this).qtip('show') //.mouseout().blur().parent().click();      
    }
  })
};
