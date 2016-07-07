var emailTemplateUI = function() {
  $(".locale-select").change(function() {
    $(".email-template").hide();
    var loc = this.value;
    console.log(loc);
    $(".email-template-"+loc).show();
  })
  $(".locale-select").change();
}

// treats <.switcher>'s direct child <a> elements as elements switchers
// on click:
//   swicher's [data-hide-class] are hidden, "current" class is removed
//   a's [data-show-class] are shown, "current" class is added
// on page load ".switcher > a[class=current]" are activated
var switcherHandler = function() {
  $(".switcher > a").click(function(event){

    var target = event.target;
    var parent = target.parentElement;
    var items = parent.children;

    for(var indx = 0; indx < items.length; indx++) {
      var item = items[indx];
      if (item === target) {
        item.classList.add('current');
        $('.' + parent.dataset.hideClass).hide();
        $('.' + item.dataset.showClass).show()
      } else {
        item.classList.remove('current')
      }
    }
  });
  $(".switcher > a[class=current]").click();
};

$(function() {
  emailTemplateUI();
  switcherHandler()
});
