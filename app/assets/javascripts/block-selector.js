$(document).ready(function() {
  $(".block-selector").each(function() {
    
    var blockSelector = $(this);
    var yesButton = blockSelector.find(".block-selector__button--yes");
    var noButton = blockSelector.find(".block-selector__button--no");
    var input = blockSelector.find(".block-selector__input");
    var innerYes = blockSelector.find(".block-selector__yes-selected");
    var innerNo = blockSelector.find(".block-selector__no-selected");
    var inputWrapper = blockSelector.find(".block-selector__checkbox-field");
    var errors = inputWrapper.find(".error")
    var removeErrors = function() {
      inputWrapper.removeClass("has_error");
      errors.text("");
    }
    console.log(yesButton.length);

    var checkValue = function() {
      if (input.attr("value") == "1") {
        yesButton.addClass("block-selector__button--selected");
        noButton.removeClass("block-selector__button--selected");
        innerYes.show();
        innerNo.hide();
      } else if (input.attr("value") == "0") {
        noButton.addClass("block-selector__button--selected");
        yesButton.removeClass("block-selector__button--selected");
        innerYes.hide();
        innerNo.show();
      } else {
        noButton.removeClass("block-selector__button--selected");
        yesButton.removeClass("block-selector__button--selected");
        innerYes.hide();
        innerNo.hide();
      }
    }


    yesButton.click(function() {
      input.attr("value","1")
      checkValue();
      removeErrors();
    });
    noButton.click(function() {
      input.attr("value", "0")
      checkValue();
      removeErrors();
    });
    checkValue();
  })
})