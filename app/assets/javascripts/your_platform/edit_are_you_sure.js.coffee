# When leaving an edit form, ask if the user is sure in order to prevent data loss.
#
# Turbolinks-related discussion: https://github.com/turbolinks/turbolinks-classic/issues/249
# Internal discussion: https://trello.com/c/ve77mrU4/1028
#
are_you_sure_to_leave_without_saving_message = ->
  I18n.translate 'are_you_sure_to_leave_without_saving'

$(document).on 'change', 'form.warn_when_leaving input, form.warn_when_leaving textarea', ->
  $(this).closest('form').addClass('dirty')

$(document).on 'submit submit.rails', 'form.warn_when_leaving', ->
  $(this).removeClass('dirty')

$(document).on 'turbolinks:before-visit', ->
  if $('form.warn_when_leaving.dirty').count() > 0
    confirm(are_you_sure_to_leave_without_saving_message())

$(document).ready ->
  $(window).off('beforeunload').on 'beforeunload', ->
    if $('form.warn_when_leaving.dirty').count() > 0
      # This needs to return the message itself. See http://stackoverflow.com/a/1889450/2066546.
      are_you_sure_to_leave_without_saving_message()
