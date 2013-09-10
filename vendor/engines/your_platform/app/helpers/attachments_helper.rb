module AttachmentsHelper
  
  # This returns the proper attachment url, which routes the download through
  # a controller.
  #
  def attachment_download_url(attachment, version = nil)
    attachment_path(id: attachment.id, basename: File.basename(attachment.filename), extension: File.extension(attachment.filename) )
  end
end
