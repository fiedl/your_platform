concern :CorporationAvatar do

  included do
    include HasAvatar
  end

  def default_avatar_path
    attachments.wappen.last.try(:medium_path)
  end

  def default_avatar_background_path
    attachments.wingolfshaus.last.try(:big_path)
  end

end