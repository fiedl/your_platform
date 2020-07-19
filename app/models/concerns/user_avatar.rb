require 'open-uri'
require 'base64'

# This module contains all the Avatar-related methods of a User.
#
# Legacy avatars are done with:
# - gravatar
# - refile (https://github.com/refile/refile)
#
# Current avatars: carrierwave via attachment association
#
concern :UserAvatar do

  included do
    attachment :avatar, type: :image  # refile

    def refile_avatar
      avatar
    end

    has_many :attachments, as: :parent, dependent: :destroy, autosave: true

    def avatar_url
      if avatar_path.start_with? "http"
        avatar_path
      else
        AppVersion.root_url + avatar_path
      end
    end
  end

  def carrierwave_avatar_attachment
    @carrierwave_avatar_attachment ||= attachments.where(title: "avatar").first_or_initialize
  end

  def carrierwave_avatar
    carrierwave_avatar_attachment.file
  end

  def carrierwave_avatar=(file)
    carrierwave_avatar_attachment.file = file
    carrierwave_avatar_attachment.save
  end

  def avatar_path
    if refile_avatar.present?
      Refile.attachment_url(self, :avatar, :fill, 300, 300)
    elsif carrierwave_avatar.present?
      carrierwave_avatar.url(:medium)
    else
      default_avatar_path
    end
  end

  def carrierwave_avatar_background_attachment
    @carrierwave_avatar_background_attachment ||= attachments.where(title: "avatar_background").first_or_initialize
  end

  def carrierwave_avatar_background
    carrierwave_avatar_background_attachment.file
  end

  def carrierwave_avatar_background=(file)
    carrierwave_avatar_background_attachment.file = file
    carrierwave_avatar_background_attachment.save
  end

  def avatar_background_path
    if carrierwave_avatar_background.present?
      carrierwave_avatar_background.url(:big)
    else
      corporations.first.try(:avatar_url)
    end
  end

  def default_avatar_path
    if female?
      "https://github.com/fiedl/your_platform/raw/master/app/assets/images/img/avatar_female_480.png"
    else
      "https://github.com/fiedl/your_platform/raw/master/app/assets/images/img/avatar_male_480.png"
    end
  end

end