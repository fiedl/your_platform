$(document).on 'click', '.tags .fa-tag', ->
  $(this).next('.best_in_place').data('bestInPlaceEditor').activate()

$(document).on 'click', '.tagcloud .edit_tag_cloud', ->
  $(this).prev('.best_in_place').data('bestInPlaceEditor').activate()
  false

# The tag autocompletion is handled in `auto-completion.js.coffee`.