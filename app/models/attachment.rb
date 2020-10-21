class Attachment < ApplicationRecord

  belongs_to :parent, polymorphic: true
  belongs_to :parent_group, -> { where(attachments: {parent_type: "Group"}).includes(:attachments) }, foreign_key: :parent_id, class_name: "Group"
  belongs_to :parent_page, -> { where(attachments: {parent_type: "Page"}).includes(:attachments) }, foreign_key: :parent_id, class_name: "Page"

  mount_uploader :file, AttachmentUploader

  before_save :update_file_attributes
  after_create :set_default_title_if_empty
  before_destroy :remove_file!

  scope :logos, -> { where('title like ?', "%logo%") }
  scope :documents, -> { where('content_type like ? or content_type like?', "application/pdf", "%document%") }
  scope :belongs_to_page_without_group, -> { includes(parent_page: :ancestor_groups).where(groups: {id: nil}) }

  include Flags
  include HasAuthor
  # include AttachmentSearch  # It's not ready, yet. https://trello.com/c/aYtvpSij/1057
  include DocumentTags

  def title
    super || filename.try(:gsub, "_", " ")
  end

  def scope
    parent.try(:group) || parent.parents.first || parent
  end
  def scope_title
    scope.try(:title)
  end

  def groups
    if parent.kind_of? Post
      parent.parent_groups
    elsif parent.kind_of? Page
      [parent.group]
    else
      []
    end
  end

  def thumb_url
    AppVersion.root_url + thumb_path
  end
  def thumb_path
    url = file.url if has_type?("svg")
    url ||= file.url(:thumb) if has_type?("image") or has_type?("pdf")
    url ||= file.url(:video_thumb) if has_type?("video")
    url ||= helpers.image_path('file.png')
    url
  end

  def medium_url
    AppVersion.root_url + medium_path if medium_path.present?
  end
  def medium_path
    url = file.url if has_type?("svg")
    url ||= file.url(:medium) if has_type?("image") or has_type?("pdf")
    url
  end

  def big_url
    AppVersion.root_url + big_path if big_path.present?
  end
  def big_path
    url = file.url if has_type?("svg")
    url ||= file.url(:big) if has_type?("image") or has_type?("pdf")
    url
  end

  def has_type?(type)
    self.content_type.to_s.include? type
  end

  def filename
    self.file.to_s.split( "/" ).last if self.file
  end

  def file_url
    AppVersion.root_url + file.url if file.url.present?
  end

  def file_path
    file.try(:url)
  end

  def file_size_human
    helpers.number_to_human_size( self.file_size )
  end

  def image?
    self.content_type.include? 'image'
  end

  def video?
    self.content_type.include? 'video'
  end

  def document?
    pdf? || office_document?
  end

  def pdf?
    self.content_type.include? 'pdf'
  end

  def office_document?
    self.content_type.include?("document")
  end

  def self.find_by_type( type )
    where( "content_type like ?", "%" + type + "%" )
  end
  def self.by_type(type)
    find_by_type(type)
  end

  def self.find_without_types( *types )
    self.all.to_a.collect do |attachment|
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

  def as_json(*args)
    super.merge({
      file_path: file_path,
      author_title: author.try(:title),
      parent_title: parent.try(:title)
    })
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
      self.save
    end
  end

end
