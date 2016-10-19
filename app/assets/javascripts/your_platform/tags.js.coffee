$(document).on 'click', '.tags .glyphicon-tag', ->
  $(this).next('.best_in_place').data('bestInPlaceEditor').activate()

# The tag autocompletion is handled in `auto-completion.js.coffee`.