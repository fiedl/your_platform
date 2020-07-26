# Users, groups, and possibly other objects can have avatars.
# Avatar images are stored as attachments to the objects.
# Previously, we've used refile and gravatar as well.
# Gravatar has been removed due to privacy considerations.
# Refile is still used in a read-only way to preserve
# previously uploaded avatars.
#
concern :HasAvatar do
  included do
    include AvatarAttachments
    include AvatarBackgroundAttachments
    include RefileAvatar

    def avatar_path
      avatar_attachment_path || refile_avatar_path || default_avatar_path
    end

    def avatar_url
      avatar_path
    end

    def avatar_background_path
      customized_avatar_background_path || default_avatar_background_path
    end

    def customized_avatar_background_path
      avatar_background_attachment_path
    end

    def avatar_background=(file)
      self.avatar_background_attachment = file
    end

    def avatar=(file)
      self.avatar_attachment = file
    end
  end
end

concern :AvatarAttachments do
  included do
    has_many :avatar_attachments, -> { where(title: 'avatar') }, class_name: "Attachment", as: :parent
    has_many :avatar_background_attachments, -> { where(title: 'avatar_background') }, class_name: "Attachment", as: :parent
  end

  def avatar_attachment_path
    avatar_attachments.last.try(:medium_path)
  end

  def avatar_attachment=(file)
    avatar_attachments.create file: file
  end
end

concern :AvatarBackgroundAttachments do
  included do
    has_many :avatar_background_attachments, -> { where(title: 'avatar_background') }, class_name: "Attachment", as: :parent
  end

  def avatar_background_attachment_path
    avatar_background_attachments.last.try(:big_path)
  end

  def avatar_background_attachment=(file)
    avatar_background_attachments.create file: file
  end
end

concern :RefileAvatar do
  included do
    # The `attachment` method is provided by refile.
    # https://github.com/refile/refile
    #
    attachment :avatar, type: :image if has_attribute? :avatar_id
  end

  def refile_avatar
    avatar if respond_to? :avatar
  end

  def refile_avatar_path
    Refile.attachment_url(self, :avatar, :fill, 500, 500) if refile_avatar.present?
  end
end

