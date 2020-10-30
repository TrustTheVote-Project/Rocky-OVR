$(document).ready(function() {
  addTooltips('.flat img.tooltip, .checkbox img.tooltip', 'top right', 'bottom left');
  addTooltips('legend img.tooltip, h3 img.tooltip', 'right center', 'left bottom');
  formatDateInputs();
  initValidations();
  if (window.isFacebookApp()) {
    // Convert all target=_blank
    $("a[target=_blank]").each(function () {
      $(this).attr("target", "_self");
    })
  }
});
