# This script removes the 'review' marker after the 'confirm' button was clicked.
#
ready = ->
  $(document).on('ajax:success', '#corporate_vita .membership', (event) ->
    $(this).removeClass("needs_review")
    $(this).find(".confirm-review-button").hide()
  )

$(document).ready(ready)

