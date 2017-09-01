$(document).ready ->

  # use it reverse in order to select the first field, not the last one.
  $('.best_in_place.show_always').get().reverse().each -> $(this).trigger('edit')

  # $('.best_in_place.click_does_not_trigger_edit')


trigger_box_edit_mode_complete_if_all_are_finished = (best_in_place)->
  box = $(best_in_place).closest('.box')
  if box.find('.best_in_place.saving').length == 0
    box.trigger('save_complete')

$(document).on 'best_in_place:before-update', '.best_in_place', ->
  $(this).addClass 'saving'
  $(this).removeClass 'success error'

$(document).on 'ajax:success', '.best_in_place', ->
  $(this).removeClass 'saving'
  $(this).addClass 'success'
  $(this).effect 'highlight'
  trigger_box_edit_mode_complete_if_all_are_finished($(this))

$(document).on 'ajax:error', '.best_in_place', (request, error)->
  $(this).removeClass 'saving'
  $(this).addClass 'error'

  # This is not very helpful information :(
  console.log "best in place error"
  console.log request
  console.log JSON.stringify error

  trigger_box_edit_mode_complete_if_all_are_finished($(this))


# # https://github.com/bernat/best_in_place/blob/master/lib/assets/javascripts/best_in_place.purr.js
# BestInPlaceEditor.defaults.purrErrorContainer = "<div class='alert alert-danger'></div>"
#
# $(document).on 'best_in_place:error', '.best_in_place', (event, request, error)->
#   console.log "best in place error"
#   console.log JSON.stringify(request)
#   if request.responseText?
#     jQuery.each jQuery.parseJSON(request.responseText), (index, value)->
#       value = (index + " " + value.toString()) if (typeof value == "object")
#       container = jQuery(BestInPlaceEditor.defaults.purrErrorContainer).html(value)
#       container.purr()


# Clicking on ajax checkboxes submits their forms.
$(document).on 'change', '.ajax_check_box', ->
  $(this).closest('form').submit()