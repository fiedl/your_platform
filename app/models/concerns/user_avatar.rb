concern :UserAvatar do

  included do
    include HasAvatar
  end

  def default_avatar_path
    if female?
      "/images/avatar_female_480.png"
    else
      "/images/avatar_male_480.png"
    end
  end

  def default_avatar_background_path
    corporations.first.try(:avatar_background_path)
  end

end