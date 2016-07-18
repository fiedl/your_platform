$(document).ready ->
  #App.wysiwyg_editors = []

  if $('.wysiwyg.editable').size() > 0
    $('.wysiwyg.editable').each ->
      editable = $(this)
      toolbar = editable.prev('.wysihtml-toolbar')

      # https://github.com/NARKOZ/wysihtml5-rails/blob/master/vendor/assets/javascripts/parser_rules/simple.js
      parser_rules = {
        tags: {
          strong: 1,
          b:      1,
          i:      1,
          em:     1,
          br:     1,
          p:      1,
          div:    {
            check_attributes: {
              contenteditable: "any",
              "*": "any"
            }
          },
          span:   {},
          ul:     1,
          ol:     1,
          li:     1,
          h1:     {rename_tag: 'h2'},
          h2:     1
          h3:     1,
          blockquote: 1,
          img: {
            check_attributes: {
              width: 'dimension',
              alt: 'alt',
              src: 'url',
              height: 'dimension'
            }
          },
          a:      {
            check_attributes: {
              href:   "any"
            }
          }
        },
        classes: "any"
      }

      editor = new wysihtml.Editor editable.get(0), {
        toolbar: toolbar.get(0),
        showToolbarAfterInit: false,
        parserRules: parser_rules,
        classNameCommandActive: 'active',
        useLineBreaks: editable.hasClass('multiline')
      }

      #App.wysiwyg_editors.push editor

      editable.data('editor', editor)
      editable.on 'edit', ->
        editor.enable()
        editable.addClass('active')
        toolbar.show('blind')


      editable.on 'save', ->
        editor.disable()
        editable.removeClass('active')
        toolbar.hide('blind')

        # Replace video galleries with the link in order to persist them correctly.
        editable.find('.wysihtml-uneditable-container.for-video-gallery').each ->
          video_url = $(this).find('.video-gallery').data('video-url')
          $(this).replaceWith(video_url)

        html = editor.getValue()
        url = editable.data('url')
        $.ajax {
          type: 'POST',
          url: url,
          data: {
            _method: 'PATCH',
            "#{editable.data('object-key')}": { # e.g. "page"
              "#{editable.data('attribute-key')}": html # e.g. "content"
            }
          },
          success: (result)->
            editor.setValue(result['display_as']) if result
            editable.effect('highlight')
            App.galleries.process(editable)
        }

      editable.on 'cancel', ->
        editor.disable()
        editable.removeClass('active')
        toolbar.hide('blind')

      editor.on 'load', ->
        toolbar.find('a').attr('href', '#')
        editor.disable()

$(document).on 'keydown', '.wysihtml-sandbox', (e)->
      if e.keyCode == 27 # escape
        $(this).trigger('cancel')
        $(this).closest('.edit_mode_group').trigger('cancel')
      if e.keyCode == 13 # enter
        unless $(this).hasClass('multiline')
          $(this).trigger('save')
          $(this).closest('.edit_mode_group').trigger('save')


$(document).on 'click', '.wysihtml-sandbox', (e)->
  if $(this).data('activate') == "click"
    $(this).trigger('edit')
    $(this).data('editor').focus()

# https://github.com/Nerian/bootstrap-wysihtml5-rails#if-using-turbolinks
$(document).on 'page:load', ->
  window['rangy'].initialized = false

# This fixes DOMException: WRONG_DOCUMENT_ERR:
#
# https://github.com/Voog/wysihtml/issues/109
# https://github.com/Voog/wysihtml/pull/210
# https://github.com/Voog/wysihtml/pull/212
#
$(document).on 'page:fetch', ->
  $('.wysiwyg.editable').each ->
    $(this).data('editor').destroy()
    $(this).data('editor', null)