$(document).ready ->
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
        div:    {},
        span:   {},
        ul:     1,
        ol:     1,
        li:     1,
        h1:     {rename_tag: 'h2'},
        h2:     1
        h3:     1,
        blockquote: 1,
        a:      {
          set_attributes: {
            target: "_blank",
            rel:    "nofollow"
          },
          check_attributes: {
            href:   "url" # important to avoid XSS
          }
        }
      }
    }

    editor = new wysihtml5.Editor editable.get(0), {
      toolbar: toolbar.get(0),
      showToolbarAfterInit: false,
      parserRules: parser_rules,
      classNameCommandActive: 'active'
    }

    editable.data('editor', editor)
    editable.on 'edit', ->
      editor.enable()
      toolbar.show('blind')

    editable.on 'save', ->
      editor.disable()
      toolbar.hide('blind')

      html = editor.getValue()
      url = editable.data('url')
      $.ajax {
        type: 'POST',
        url: url,
        data: {
          _method: 'PATCH',
          page: {
            content: html
          }
        },
        success: (result)->
          editor.setValue(result['display_as'])
          editable.effect('highlight')
      }

    editable.on 'cancel', ->
      editor.disable()
      toolbar.hide('blind')

    editor.on 'load', ->
      toolbar.find('a').attr('href', '#')
      editor.disable()
