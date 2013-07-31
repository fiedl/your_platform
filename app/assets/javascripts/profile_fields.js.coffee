# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

ready = ->

 # # Entfernen-Button der Profilfelder mit Funktion ausstatten.
 # # ------------------------------------------------------------------------------------------
 # $( document ).on( 'click', ".profile_field * .remove_button", (event) ->
 #
 #   # Per Ajax die Seite im Hintergrund aufrufen, zu der der Entfernen-Button auch
 #   # ohne JavaScript führen würde.
 #   $.ajax(
 #     url: $( this ).attr( 'href' ),
 #     type: 'DELETE'
 #   )
 #
 #   # Per jQuerry-Effekt das bearbeitbare Feld ausblenden.
 #   $( this ).closest( ".profile_field" ).hide( 'blind' ).remove()
 #
 #   # Das Klick-Ereignis an dieser Stelle abbrechen, sodass der Button
 #   # nicht doch noch ohne JavaScript zur hinterlegten Seite weiterleitet.
 #   event.preventDefault()
 #
 # )

  # Wingolfspost-Flag
  # ------------------------------------------------------------------------------------------
  $(document).on('change', ".wingolfspost * input", (event) ->
    if $(this).prop('checked')
      profile_field_id = $(this).closest('.wingolfspost').data('profileFieldId')
      $(".wingolfspost").removeClass('flagged').addClass('unflagged')
      $(".wingolfspost.profile_field_" + profile_field_id).addClass('flagged').removeClass('unflagged')
      $.ajax(
        url: $(this).closest('.wingolfspost').data('updateJsonUrl'),
        type: 'POST',
        data: { _method: 'PUT', profile_field: { wingolfspost: true  } },
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


$(document).ready(ready)
$(document).on('page:load', ready)
