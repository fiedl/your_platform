# Best-in-place input fields are too large in edit mode. Auto-size them.
# https://trello.com/c/MA47o4Yv/1454-edit-mode-input-felder-zu-groß
# https://stackoverflow.com/a/38867270/2066546

$(document).on 'click keyup paste focus', '.best_in_place input[type="text"]', ->
  console.log $(this)

  input = $(this)

  # calculate the required size by using a virtual span field.
  input.before("<span id='virtual-span-field'></span>")
  virtual = $('#virtual-span-field')

  virtual.text(input.val())
  width = virtual.width() + 10 # in order to have the text not jump when typing
  width = 20 if width < 20
  virtual.remove()

  input.width(width)
