function registerTouch() {};

function hideErrors() {
  $('.error').each(function(){ $(this).css('opacity', 0); });
};

function revealErrors() {
  $('.error').each(function() { $(this).animate({opacity: 1}); });
};

function toggleFieldSet(checkbox, set, rule, speed) {
	if ( $(checkbox).is(':checked') ) {
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

function checkboxTogglesSet(checkbox, set, rule) {
  toggleFieldSet(checkbox, set, rule, 0);
  $(checkbox).change(function () {
    toggleFieldSet(checkbox, set, rule, 'fast');
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
