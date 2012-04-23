# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->

  # Zu versteckende Tools der Boxen ausblenden.
  $(".box_toolbar .button.hidden").removeClass( "hidden" ).css( "display", "inline-block" ).hide()
  $(".box_edit_button").show()

  # Der Bearbeiten-Button der Box schaltet den Bearbeiten-Modus
  # für alle Felder in der Box ein.
  $(".box_edit_button").click( ->

    # Box identifizieren.
    box = $(this).closest( ".box" )

    # Modaler Effekt
    make_box_modal( box )

    # Bearbeiten-Buttons umschalten.
    enter_edit_mode_of_box( box )

    # Bearbeiten-Modus auf enthaltene Felder übertragen.
    box.find( "span.editable" ).each ->
      $(this).addClass( "box_edit_mode" ).trigger( "edit" )

    # Hinzufügen-Button ganz am Ende sichtbar machen.
    box.find( ".add_button" ).show()
    #image_tag( "../images/tools/add.png", alt: t( :add ), title: t( :add ), class: "button add_button" )
    # TODO: Das muss noch in die Box.

  )

  # Box modal machen
  make_box_modal = (box) ->
    modal_box = box
    modal_box.addClass( "modal" )
    $("body").append( "<div class='modal_bg'></div>" )
    $("div.modal_bg").hide().fadeIn().click( ->

      # Wenn man auf den abgedunkelten Berreich außerhalb der Box klickt, wird
      # der Bearbeien-Modus beendet und gespeichert.
      modal_box.find(".box_save_button").click()

    )

  # Animation: Bearbeiten-Modus einer Box einschalten.
  enter_edit_mode_of_box = (box) ->
    box.find( ".box_edit_button" ).hide()
    box.find(".box_save_button, .box_cancel_button").show()

  # Animation: Bearbeiten-Modus einer Box beenden.
  end_edit_mode_of_box = (box) ->
    box.find(".box_save_button, .box_cancel_button").hide()
    box.find(".box_edit_button").show()
    $("div.modal_bg").fadeOut( ->
      $(this).remove()
      $(".modal").removeClass("modal")
    )

  # Box speichern.
  $(".box_save_button").click( ->
    $(this).effect( "pulsate", { times: 2 }, "fast", ->
      box = $( this ).closest( ".box" )
      box.find( ".editable" ).each ->
        $( this ).removeClass( "box_edit_mode" ).trigger( "save" )
      end_edit_mode_of_box( box )
    )
  )

  # Box-Bearbeiten-Modus abbrechen.
  $(".box_cancel_button").click( ->
    $(this).effect( "pulsate", { times: 2 }, "fast", ->
      box = $( this ).closest( ".box" )
      box.find( ".editable" ).each ->
        $( this ).removeClass( "box_edit_mode" ).trigger( "cancel" )
      end_edit_mode_of_box( box )
    )
  )
