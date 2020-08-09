concern :GroupProfile do

  def phone_field
    phone_profile_fields.first
  end

  def facebook_url
    profile_fields.where(label: "Facebook", type: "ProfileFields::Homepage").first.try(:value)
  end

  def youtube_url
    profile_fields.where(label: "YouTube", type: "ProfileFields::Homepage").first.try(:value)
  end

  def instagram_url
    profile_fields.where(label: "Instagram", type: "ProfileFields::Homepage").first.try(:value)
  end

end