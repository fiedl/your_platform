class Attachment < ActiveRecord::Base
  attr_accessible :description, :file, :parent_id, :parent_type, :title

  belongs_to :parent, polymorphic: true

  mount_uploader :file, AttachmentUploader

  before_save :update_file_attributes
  before_create :set_default_title_if_empty
  before_destroy :remove_file!

  def thumb_url
    url = file.url( :thumb ) if has_type?( "image" ) or has_type?( "pdf" )
    url = file.url( :video_thumb ) if has_type?( "video" )
    url = helpers.image_path( 'file.png' ) unless url
    return url
  end

  def has_type?( type )
    self.content_type.include? type
  end

  def filename 
    self.file.to_s.split( "/" ).last if self.file
  end

  def file_size_human
    helpers.number_to_human_size( self.file_size )
  end

  def self.find_by_type( type )
    where( "content_type like ?", "%" + type + "%" )
  end

  def self.find_without_types( *types )
    where( true ).all.collect do |attachment|
      re = attachment
      for type in types
        if not attachment.content_type
          re = []
        else
          if attachment.content_type.include? type
            re = []
          end
        end
      end
      re
    end.flatten
  end

  private

  def helpers
    ActionController::Base.helpers
  end

  def update_file_attributes
    if file.present? and file_changed?
      self.file_size = file.file.size
      self.content_type = file.file.content_type
    end
    true
  end

  def set_default_title_if_empty
    if file.present? && file.filename.present? && file_changed?
      self.title ||= File.basename(file.filename, '.*').titleize
    end
  end

end
