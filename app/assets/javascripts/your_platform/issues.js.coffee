
# issues#index
# =======================================================================================

$(document).ready ->
  $('.thanks_for_fixing_issue').hide()
  $('.scanning_issue').hide()


$(document).on 'save', 'body.issues .box .editable.value', ->
  profile_field = $(this)
  profile_field.closest('.box').find('.scanning_issue').show()

$(document).on 'save_complete', 'body.issues .box', ->
  box = $(this)
  profile_field = $(this).find('.editable.value')

  url = profile_field.data('profile-field-json-path') if profile_field.data('profile-field-json-path')?
  url = url + '?scan_for_issues=true'

  $.ajax
    url: url,
    type: 'GET',
    success: (result)->
      box.find('.scanning_issue').hide()
      if result.issues.length == 0
        box.find('.thanks_for_fixing_issue').show()
        box.find('.description_container').hide()
        box.find('.original_value_container').hide()
    error: ->
      box.find('.scanning_issue').hide()
      box.addClass('error')

$(document).on 'click', 'body.issues .destroy-container .btn', ->
  $(this).closest('.box').find('.destroy-container').hide()
  $(this).closest('.box').find('.thanks_for_fixing_issue').show()
  $(this).closest('.box').find('.description_container').hide()
  $(this).closest('.box').find('.original_value_container').hide()


# issues#new
# =======================================================================================

$(document).ready ->
  $('body.issues textarea#description').autosize()
