module AttachmentsHelper

  def inline_pictures_for(attachment_parent)
    if (image_attachments = attachment_parent.attachments.find_by_type("image")) && image_attachments.try(:any?)
      render partial: 'attachments/pictures', locals: {attachments: image_attachments, inline: true}
    end
  end

end
