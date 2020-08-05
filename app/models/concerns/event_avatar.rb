concern :EventAvatar do

  included do
    include HasAvatar
  end

  def default_avatar_path
    group.try(:avatar_path)
  end

  def default_avatar_background_path
    group.try(:avatar_background_path)
  end

end