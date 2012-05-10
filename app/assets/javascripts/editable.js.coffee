# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

        # Jedes editierbare Feld soll auf einen Doppelklick in
        # in den Bearbeiten-Modus wechseln.
        $( "span.editable" ).live( "dblclick", ->
                $( this ).trigger( "edit" )
        )

        # Bearbeiten-Modus der einzelnen editierbaren Felder.
        $( "span.editable" ).live( "edit", ->

                # Wenn sich das Feld bereits im Bearbeiten-Modus befindet,
                # abbrechen. Sonst die Markierung für den Modus setzen.
                return if $( this ).hasClass( "edit" )
                $( this ).addClass( "edit" )
                $( this ).removeClass( "show" )

                # Wenn die ganze Box bearbeitet wird, muss sich das Objekt
                # leicht anders verhalten, d.h. nicht auf alle Einzel-Ereignisse
                # reagieren.
                box_edit_mode = true if $( this ).hasClass( "box_edit_mode" ) or $( this ).closest( ".box" ).hasClass( "edit_mode" )

                # Die Bearbeiten-Version des Feldes laden.
                $( this ).load(
                        $( this ).attr( 'data-edit-url' ),
                        null,
                        () ->
                                # Nach dem Laden den Tastatur-Fokus setzen.
                                $( this ).find( "input:not(.label)" ).focus() unless box_edit_mode
                )

                # Bei Klick außerhalb speichern.
                unless box_edit_mode
                        $( this ).bind( "clickoutside", ->
                                $( this ).trigger( "save" )
                        )

                # Tastatur-Ereignisse:
                # Bei ESC abbrechen, bei ENTER speichern.
                unless box_edit_mode
                        editable_span = $( this )
                        $( editable_span ).keyup( (event) ->
                                if event.keyCode == 13
                                        unless editable_span.find( "textarea" ).length > 0
                                                editable_span.trigger( "save" )
                                if event.keyCode == 27
                                        editable_span.trigger( "cancel" )
                        )


                # Speichern-Ereignis:
                $( this ).bind( "save", ->
                        save( $( this ) )
                )

                # Speichern-Routine:
                save = ( editable_span ) ->
                        editable_span.load(
                                editable_span.attr( 'data-update-url' ),
                                editable_span.find( "form" ).serialize()
                        )
                        exit_edit_mode( editable_span )

                # Abbrechen-Ereignis:
                $( this ).bind( "cancel", ->
                        cancel( $( this ) )
                )

                # Abbrechen-Routine:
                cancel = ( editable_span ) ->
                        editable_span.load( editable_span.attr( 'data-show-url' ) )
                        exit_edit_mode( editable_span )

                # Bearbeiten-Modus-Verlassen-Routine:
                exit_edit_mode = ( editable_span ) ->
                        unbind_edit_mode_events( editable_span )
                        editable_span.removeClass( "edit" )
                        editable_span.addClass( "show" )

                # Event-Handler-Entfernen-Routine:
                unbind_edit_mode_events = ( editable_span ) ->
                        editable_span.unbind( "clickoutside" )
                        editable_span.unbind( "keyup" )

        )

