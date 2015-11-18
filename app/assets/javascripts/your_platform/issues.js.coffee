$(document).ready ->
  $('.thanks_for_fixing_issue').hide()
  $('.scanning_issue').hide()
  $('body.issues .box .value.editable').bind 'save', ->
    profile_field = $(this)
    url = profile_field.data('bip-url') + '.json?scan_for_issues=true' # "bip" is "best in place"
    profile_field.closest('.box').find('.scanning_issue').show()
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
