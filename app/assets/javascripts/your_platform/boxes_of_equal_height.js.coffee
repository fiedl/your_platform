make_heights_equal = (cols)->
  col_heights = []
  for col in cols
    h = 0
    $(col).find('.box').each ->
      old_height = $(this).css('height')
      $(this).css('height', '')
      h += $(this).height()
      if $(this).find('.panel-footer')
        h += $(this).find('.panel-footer').height() * 2
      $(this).css('height', old_height) # in order to avoid animation glitches
    col_heights.push h
  max_height = Math.max.apply(Math, col_heights)
  for col in cols
    $(col).data('making-heights-equal', true)
    if Math.abs($(col).find('.box').first().height() - max_height) > 10
      $(col).find('.box').first().animate {height: max_height, 1}
    else
      $(col).find('.box').first().css('height', "#{max_height}px")
    $(col).data('making-heights-equal', null)

App.adjust_box_heights_for = (this_col) ->
  unless this_col.data('making-heights-equal')
    if this_col.closest('.row-eq-height')
      cols_to_adjust_height = $(".row-eq-height .col").filter (index)->
        $(this).position().top == this_col.position().top
      make_heights_equal(cols_to_adjust_height)

App.adjust_box_heights = ->
  $('.row-eq-height .col').each ->
    this_col = $(this)
    App.adjust_box_heights_for this_col

$(document).ready ->
  App.adjust_box_heights()
