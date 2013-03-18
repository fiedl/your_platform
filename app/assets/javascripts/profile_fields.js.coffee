# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

ready = ->

        # Entfernen-Button der Profilfelder mit Funktion ausstatten.
        $( document ).on( 'click', ".profile_field * .remove_button", (event) ->

                # Per Ajax die Seite im Hintergrund aufrufen, zu der der Entfernen-Button auch
                # ohne JavaScript führen würde.
                $.ajax(
                        url: $( this ).attr( 'href' ),
                        type: 'DELETE'
                )

                # Per jQuerry-Effekt das bearbeitbare Feld ausblenden.
                $( this ).closest( ".profile_field" ).hide( 'blind' ).remove()

                # Das Klick-Ereignis an dieser Stelle abbrechen, sodass der Button
                # nicht doch noch ohne JavaScript zur hinterlegten Seite weiterleitet.
                event.preventDefault()

        )

$(document).ready(ready)
$(document).on('page:load', ready)
