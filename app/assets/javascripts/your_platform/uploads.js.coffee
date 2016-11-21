class App.UploadBox

  upload_counter: 0
  upload_done_counter: 0
  root_element: {}

  # Initialize like this:
  #
  #    attachments_section = ').attachments')
  #    upload_box = new App.UploadBox(attachments_section)
  #
  # If there is only upload box on the page,
  # giving $(document) as root_element will suffice.
  #
  #    root_element = $(document)
  #    upload_box = new App.UploadBox(root_element)
  #
  constructor: (root_element)->
    @root_element = root_element
    @unbind_previous_fileupload()
    @bind_fileupload()
    @bind_drag_events()

  unbind_previous_fileupload: ->
    @find('form.new_attachment').unbind()
    @find('form.new_attachment').off()

  # This binds the fileupload callbacks to the upload form field.
  # The `fileupload` method is provided by https://github.com/blueimp/jQuery-File-Upload.
  # The `form.new_attachment` element is inserted by form_for(attachments.build) in the view.
  #
  bind_fileupload: ->
    self = this  # since `this` can be redefiend
    self.find('form.new_attachment').fileupload
      dataType: "json"
      dropZone: self.find('.attachment_drop_field')
      add: (e, data) -> self.file_added(data)
      progress: (e, data) -> self.show_uploading()
      done: (e, data) -> self.upload_done()
      fail: (e, data)-> self.upload_failed()

  file_added: (data)->
    @upload_counter += 1
    file = data.files[0]
    data.submit()
  upload_done: ->
    @upload_done_counter += 1
    if @upload_done_counter >= @upload_counter
      @show_success()
  upload_failed: ->
    @upload_done_counter += 1
    @show_uploading()
    if @upload_done_counter >= @upload_counter
      @find('p.uploading').text I18n.t 'upload_failed_please_contact_support'
    else
      @find('p.uploading small:first').text I18n.t 'upload_failed_please_contact_support'

  # This is just a shortcut to find a dom element in the root element
  # of this uploader.
  #
  find: (selector)->
    @root_element.find(selector)

  show_uploading: ->
    @find('.attachment_drop_field').addClass('uploading')
    @find('.attachment_drop_field').removeClass('success')
    @find('p.drop_attachments_here').hide()
    @find('p.success').hide()
    @find('p.uploading').removeClass('hidden').show()
    @find('.attachment_drop_field').find('form').hide()
    @find('.upload_counter').html("" + @upload_done_counter + " / " + @upload_counter)

  show_success: ->
    @find('.attachment_drop_field')
      .removeClass('uploading').addClass('success')
    @find('p.uploading').hide()
    @find('p.success').removeClass('hidden').show()
    @refresh_attachments_section()

  bind_drag_events: ->
    self = this
    self.find('.attachment_drop_field').on 'dragover', ->
      $(this).addClass('over')
      $(this).removeClass('success')
      self.find('p.success').hide()
      self.find('p.drop_attachments_here').show()
    self.find('.attachment_drop_field').on 'dragleave', ->
      $(this).removeClass('over')
    self.find('.attachment_drop_field').on 'drop', ->
      $(this).removeClass('over')
      self.show_uploading()

  refresh_attachments_section: ->
    @root_element.ajax_reload(@parent_url(), '#attachments, #inline-pictures, .attachments')

  parent_url: ->
    @find('.box.upload_attachment').attr('data-parent-url')