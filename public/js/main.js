$(function() {

  $('#order').change(function() {
    var val = $(this).val();
    if (val == "default") {
      $("#order-btn").prop("disabled", true);
    } else {
      $("#order-btn").prop("disabled", false);
    }
  });

});
