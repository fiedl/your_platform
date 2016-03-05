

# The <span class="edit_mode_group"></span> elements should be modal when in edit mode.
# That means that everything else should be greyed out.
# If the user clicks on the shaded (grey) area outside, the edit_mode_group is saved.

$( document ).on( "edit", ".edit_mode_group", ->
  if $( document ).find( ".edit-mode-modal" ).size() == 0
    #unless $( this ).hasClass( "edit-mode-modal" )
    modal_edit_mode_group = $( this )
    $( this ).addClass( "edit-mode-modal" )
    $( "body" ).append( "<div class='edit-mode-modal-bg'></div>" )
    $( "div.edit-mode-modal-bg" ).hide().fadeIn().click( ->
      modal_edit_mode_group.trigger( "save" )
    )
)

$( document ).on( "save cancel", ".edit_mode_group", ->
  if $( this ).hasClass( "edit-mode-modal" )
    unless $( this ).hasClass( "animating" )
      $( this ).addClass( "animating" )
      setTimeout( ->
        $( "div.edit-mode-modal-bg" ).fadeOut( ->
          $( this ).remove()
          $( ".edit-mode-modal" ).removeClass( "edit-mode-modal animating" )
        )
      , 300 )
)

