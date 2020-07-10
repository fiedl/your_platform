
# Review buttons
# ------------------------------------------------------------------------------------------
$(document).on 'click', '.address_needs_review .confirm-review-button', ->
  wrapper = $(this).closest('.address_needs_review')
  wrapper.find('.label')
    .removeClass('label-warning').addClass('label-success')
    .text(I18n.t('thanks'))
  setTimeout ->
    wrapper.remove()
  , 800


# Benutzer versteckt
# ------------------------------------------------------------------------------------------
$(document).on('change', ".user_hidden_flag * input", (event) ->
  user_id = $(this).closest('.user_hidden_flag').data('userId')
  flagged = false
  if $(this).prop('checked')
    $(".user_hidden_flag").addClass('flagged').removeClass('unflagged')
    flagged = true
  else
    $(".user_hidden_flag").removeClass('flagged').addClass('unflagged')
  $.ajax(
    url: $(this).closest('.user_hidden_flag').data('updateJsonUrl'),
    type: 'POST',
    data: { _method: 'PUT', user: { hidden: flagged } },
    dataType: 'json'
  )
)
