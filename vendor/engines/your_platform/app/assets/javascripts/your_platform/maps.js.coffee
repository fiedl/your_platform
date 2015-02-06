$(document).ready ->
  
  $(document).on 'edit', '.map.do_not_show_in_edit_mode', ->
    #
    # Hide this map when entering edit mode. Do not show it afterwards,
    # since the map is only updated on page reload, not via javascript.
    #
    # Since edit_mode uses hide() and show(), we need to use the display
    # css attribute.
    #
    $(this).closest('.box').removeClass('with_small_map')
    $(this).remove()
    