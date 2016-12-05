$(document).ready ->
  $(document).process_comment_tools()

$.fn.process_comment_tools = ->
  $(this).find('.new_comment .comment-tools').hide()

$(document).on 'change keyup paste', '.new_comment textarea', ->
  if $(this).val() != ""
    $(this).closest('.new_comment').find('.comment-tools').show()
    $(this).autosize()
  else
    $(this).closest('.new_comment').find('.comment-tools').hide()

$(document).on 'focus', '.new_post textarea', ->
  if $(this).val() != ""
    $(this).closest('.new_comment').find('.comment-tools').show()
