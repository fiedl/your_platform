concern :GroupAvatar do

  included do
    include HasAvatar
  end

  def default_avatar_path
    corporation.try(:avatar_path)
  end

  def default_avatar_background_path
    corporation.try(:avatar_background_path) || Attachment.by_type("image").where(parent_type: "Event", parent_id: event_ids).last.try(:medium_path)
  end

end