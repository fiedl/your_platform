class App.CodeHighlighting

  process: (root_element)->
    root_element.find('pre code').each (i, block)->
      unless $(block).hasClass('')
        $(block).prettyPre()
        App.hljs.highlightBlock(block)

App.code_highlighting = new App.CodeHighlighting()

$(document).ready ->
  App.code_highlighting.process($('body'))