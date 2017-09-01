
# Adress profile fields
# ------------------------------------------------------------------------------------------
$(document).on 'click', '.address_profile_field.value.can_edit', ->
  $(this).closest('.box').trigger('edit')

$(document).on 'best_in_place:before-update', '.address_profile_field.value.editable .best_in_place', ->
  $(this).find('.display_html').html("...")

$(document).on 'save_complete', '.box', ->
  $(this).find('.address_profile_field.value.editable').each ->
    url = $(this).data('profile-field-url') + '.json'
    value_field = $(this)
    field_to_replace = $(this).find('.display_html')
    field_to_replace.html('...')
    $.ajax
      url: url,
      type: 'GET',
      success: (result)->
        field_to_replace.html(result.display_html)
        value_field.addClass('success')
      error: ->
        value_field.addClass('error')


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


# Postal Address
# ------------------------------------------------------------------------------------------
$(document).on('change', ".postal_address * input", (event) ->
  if $(this).prop('checked')
    profile_field_id = $(this).closest('.postal_address').data('profileFieldId')
    $(".postal_address").removeClass('flagged').addClass('unflagged')
    $(".postal_address.profile_field_" + profile_field_id).addClass('flagged').removeClass('unflagged')
    $.ajax(
      url: $(this).closest('.postal_address').data('updateJsonUrl'),
      type: 'POST',
      data: { _method: 'PUT', profile_field: { postal_address: true  } },
      dataType: 'json'
    )
  )

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
