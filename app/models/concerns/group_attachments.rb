concern :GroupAttachments do

  included do
    has_many :attachments, as: :parent, dependent: :destroy
  end

  def image_attachments
    attachments.find_by_type 'image'
  end

  def image_url
    image_attachments.first.file_url
  end

end