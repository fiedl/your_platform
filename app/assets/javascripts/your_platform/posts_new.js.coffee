$(document).ready ->
  $('.new_post .preview').hide()
  $('.new_post .post_tools').hide()
  $('.new_post textarea').autosize()
  original_box_title = $('.box.first h1').text()
  
$(document).on 'change keyup paste', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()
    $('.box.first h1').text($('.new_post textarea').val().split("\n").first())
  else
    $('.new_post .post_tools').hide()
    $('.box.first h1').text(original_box_title)

$(document).on 'focus', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()

$(document).on 'click', '.preview_post', ->
  if $('.new_post textarea:visible').size() > 0
    $.ajax {
      url: $(this).attr('href'),
      data: {
        text: $('.new_post textarea').val()
      },
      success: (result)->
        $('.new_post .preview .post-body').html(result.preview)
        $('.new_post .preview').show()
        $('.new_post textarea').hide()
    }
  else
    $('.new_post .preview').hide()
    $('.new_post textarea').show().focus()
  false

$(document).on 'click', '.new_post .preview', ->
  $('.new_post .preview').hide()
  $('.new_post textarea').show().focus()
