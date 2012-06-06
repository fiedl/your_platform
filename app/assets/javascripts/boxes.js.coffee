# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  # Zu versteckende Tools der Boxen ausblenden.
  $(".box_toolbar .button.hidden").removeClass( "hidden" ).css( "display", "inline-block" ).hide()
  $(".box_edit_button").show()

  # Objekte, die nur im Edit-Mode angezeigt werden sollen, müssen auch als .editable klassifiziert werden,
  # damit die Methoden in dieser Datei richtig greifen.
  $( ".only-in-edit-mode" ).addClass( "editable" )

  # Der Bearbeiten-Button der Box schaltet den Bearbeiten-Modus
  # für alle Felder in der Box ein.
  $( ".box" ).bind( "edit", ->
    unless $( this ).hasClass ( "edit_mode" )
      box = $( this )
      box.addClass( "edit_mode" )

      # Modaler Effekt
      make_box_modal( box )

      # Die Buttons der Box für den Bearbeiten-Modus anzeigen.
      edit_mode_button_set( box )

      # Bearbeiten-Modus auf enthaltene Felder übertragen.
      # Das Reverse-Konstrukt sorgt hierbei dafür, dass das *erste* Element den
      # Tastatur-Fokus erhält.
      $( box.find( "span.editable" ).get().reverse() ).each ->
        $(this).addClass( "box_edit_mode" ).trigger( "edit" )

  )

  # Box speichern.
  $( ".box" ).bind( "save", ->
    if $( this ).hasClass( "edit_mode" )
      box = $( this )
      box.removeClass( "edit_mode" )
      box.find( ".box_save_button" ).effect( "pulsate", { times: 2 }, "fast", ->
        box.find( ".editable" ).each ->
          $( this ).removeClass( "box_edit_mode" ).trigger( "save" )
        animate_end_edit_mode( box )
      )
  )

  # Box-Bearbeiten-Modus abbrechen.
  $( ".box" ).bind( "cancel", ->
    if $( this ).hasClass( "edit_mode" )
      box = $( this )
      box.removeClass( "edit_mode" )
      box.find( ".box_cancel_button" ).effect( "pulsate", { times: 2 }, "fast", ->
        box.find( ".editable" ).each ->
          $( this ).removeClass( "box_edit_mode" ).trigger( "cancel" )
        animate_end_edit_mode( box )
      )
  )


  # == Button-Trigger ==========================================

  # Der Bearbeiten-Modus einer Box wird ausgelöst, indem man auf den Bearbeiten-Button
  # der Box klickt.
  $(".box_edit_button").click ( ->
    $( this ).closest( ".box" ).trigger( "edit" )
  )

  $(".box_save_button").click( ->
    $( this ).closest( ".box" ).trigger( "save" )
  )

  $(".box_cancel_button").click( ->
    $( this ).closest( ".box" ).trigger( "cancel" )
  )


  # == Animationen und Anzeige-Funktionen ======================

  # Box modal machen
  make_box_modal = (box) ->
    modal_box = box
    modal_box.addClass( "modal" )
    $("body").append( "<div class='modal_bg'></div>" )
    $("div.modal_bg").hide().fadeIn().click( ->

      # Wenn man auf den abgedunkelten Berreich außerhalb der Box klickt, wird
      # der Bearbeien-Modus beendet und gespeichert.
      modal_box.trigger( "save" )

    )

  # Buttons für den EditMode einer Box anzeigen.
  edit_mode_button_set = (box) ->
    box.find( ".box_edit_button" ).hide()
    box.find(".box_save_button, .box_cancel_button").show()

  # Animation: Bearbeiten-Modus einer Box beenden.
  animate_end_edit_mode = (box) ->
    box.find(".box_save_button, .box_cancel_button").hide()
    box.find(".box_edit_button").show()
    $("div.modal_bg").fadeOut( ->
      $(this).remove()
      $(".modal").removeClass("modal")
    )

