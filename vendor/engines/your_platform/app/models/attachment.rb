class Attachment < ActiveRecord::Base
  attr_accessible :description, :file, :parent_id, :parent_type, :title

  belongs_to :parent, polymorphic: true

  mount_uploader :file, AttachmentUploader

  before_destroy :remove_file!

end
