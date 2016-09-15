
# issues#index
# =======================================================================================

$(document).ready ->
  $('.thanks_for_fixing_issue').hide()
  $('.scanning_issue').hide()


$(document).on 'save', 'body.issues .box .editable.value', ->
  profile_field = $(this)
  profile_field.closest('.box').find('.scanning_issue').show()

  #profile_field_id = profile_field.data('profile-field-id')
  #url = "/api/v1/..."

  #url = profile_field.data('bip-url') if profile_field.data('bip-url')? # "bip" is "best in place"
  url = profile_field.data('profile-field-json-path') if profile_field.data('profile-field-json-path')?
  url = url + '?scan_for_issues=true'

  setTimeout ->
    $.ajax(
      url: url,
      type: 'GET',
      success: (result)->
        profile_field.closest('.box').find('.scanning_issue').hide()
        if result.issues.length == 0
          profile_field.closest('.box').find('.thanks_for_fixing_issue').show()
          profile_field.closest('.box').trigger('toggle-minimized')
      failed: ->
        profile_field.closest('.box').find('.scanning_issue').hide()
    )
  , 500

$(document).on 'click', 'body.issues .destroy-container .btn', ->
  $(this).closest('.box').find('.destroy-container').hide()
  $(this).closest('.box').find('.thanks_for_fixing_issue').show()
  $(this).closest('.box').trigger('toggle-minimized')



# issues#new
# =======================================================================================

$(document).ready ->
  $('body.issues textarea#description').autosize()
