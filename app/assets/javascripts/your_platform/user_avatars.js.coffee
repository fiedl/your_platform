$(document).ready ->
  
  # Submit the form when the image is uploaded.
  #
  $(document).on 'upload:complete', 'form.edit_user', ->
    $(this).submit()

  # When the user clicks on the image, switch to edit_mode
  # such that the user can see the upload button.
  #
  $(document).on 'click', '.avatar.thumbnail.pull-left', ->
    $(this).closest('.box').trigger('edit')