$(document).ready(function() {
  addTooltips('.tooltip img.tooltip, .flat img.tooltip, .checkbox img.tooltip', 'top right', 'bottom left');
  addTooltips('legend img.tooltip', 'right center', 'left bottom');
  formatDateInputs();
  initValidations();
  makeExternalLinksOpenInNewTab();
  if (window.isFacebookApp()) {
    // Convert all target=_blank
    $("a[target=_blank]").each(function () {
      $(this).attr("target", "_self");
    })
  }
});
