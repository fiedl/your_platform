$(document).on 'mouseenter', '.edit_button', ->
  if not $(this).closest('edit_mode_group').hasClass('currently_in_edit_mode')
    $(this).closest('.box').find('.shown_on_edit_button_hover').show(animation_preset)

$(document).on 'mouseenter', '.box_header', ->
  if not $(this).closest('edit_mode_group').hasClass('currently_in_edit_mode')
    $(this).closest('.box').find('.shown_on_box_header_hover').show(animation_preset)

$(document).on 'mouseleave', '.box_header', ->
  $(this).find('.shown_on_edit_button_hover').hide(animation_preset)
  $(this).find('.shown_on_box_header_hover').hide(animation_preset)

# In testing, with the poltergeist driver, clicking a tool button
# hits the wrong button if other buttons are faded in on hover.
#
# Therefore, we need to deactivate the animations in testing.
#
# Just to call `jQuery.fx.off = true` and `$.support.transition = false`
# as suggested in https://github.com/teampoltergeist/poltergeist/issues/530#issuecomment-226647591
# does not resolve the issue.
#
# Thus, make the animation dependent on the environment.
#
animation_preset = ->
  if $('body').data('env') == "test"
    ''
  else
    'fade'
