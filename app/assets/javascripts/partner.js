var emailTemplateUI = function() {
  $(".locale-select").change(function() {
    $(".email-template").hide();
    var loc = this.value;
    console.log(loc);
    $(".email-template-"+loc).show();
  })
  $(".locale-select").change();
}

$(function() {
  emailTemplateUI();
});
