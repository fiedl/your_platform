# https://github.com/waymondo/turboboost

$(document).on "turboboost:success", (e, flash) ->
  if flash['notice']?
    $('#flash_area').html("<div class='alert alert-success'>#{flash['notice']}</div>")

$(document).on "turboboost:error", (e, error_message) ->
  console.log(error_message)
  $('#flash_area').html("<div class='alert alert-warning'>#{error_message}</div>")
