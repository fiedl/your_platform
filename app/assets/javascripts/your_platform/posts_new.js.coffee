original_box_title = ""

$(document).ready ->
  $('.new_post .preview').hide()
  $('.new_post .post_tools').hide()
  $('.new_post textarea').autosize()
  original_box_title = $('.box.first.new_post .box_header h1').text()
  if $('.new_post .camera-button').size() > 0
    $('.new_post textarea').height($('.new_post .camera-button').height())

$(document).on 'change keyup paste', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()
    if $(this).val().split("\n").count() < 3 # for performance reasons
      $('.box.first.new_post .box_header h1').text($('.new_post textarea').val().split("\n").first())
  else
    $('.new_post .post_tools').hide()
    $('.box.first.new_post .box_header h1').text(original_box_title)
    if $('.new_post .camera-button').size() > 0
      $('.new_post textarea').height($('.new_post .camera-button').height())

$(document).on 'focus', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()


hide_preview_stuff = ->
  $('.new_post .preview').hide()
  $('.new_post .camera-button').show()
  $('.new_post textarea').show().focus()

$(document).on 'click', '.preview_post', ->
  if $('.new_post textarea:visible').size() > 0
    $('.new_post textarea').hide()
    $('.new_post .camera-button').hide()
    $.ajax {
      url: $(this).attr('href'),
      data: {
        text: $('.new_post textarea').val()
      },
      success: (result)->
        $('.new_post .preview .post-body').html(result.preview)
        $('.new_post .preview').show()
    }
  else
    hide_preview_stuff()
  false

$(document).on 'click', '.new_post .preview', ->
  hide_preview_stuff()

$(document).on 'click', '.dropdown-menu.select_post_recipient a', ->
  $('.new_post input.group_id').val($(this).data('group-id'))
  $('.btn.recipient').dropdown('toggle')
  $('.btn.recipient').removeClass('btn-primary').addClass('btn-default')
  $('.btn.recipient').text(I18n.t('recipient') + ": " + $(this).data('group-title'))
  $('.submit_post').removeClass('hidden').show()
  false

$(document).on 'click', '.new_post .camera-button', ->
  $('.new_post .post_tools').show()
  $('.new_post .post_attachment').removeClass('hidden').show()
  $('.new_post .photo_or_document_file').click()