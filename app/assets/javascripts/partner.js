var emailTemplateUI = function() {
  var handler = function() {
    $(".email-template").hide();
    var loc = $("#email-locale-select").val();
    var type = $("#email-type-select").val();
    var template_class = ".email-template-"+ type + "--" + loc;
    $(template_class).show();
  };
  $(".template-select").change(handler);
  handler();
};


$(function() {
  emailTemplateUI();
});
