concern :GroupProfile do

  def phone_field
    phone_profile_fields.first
  end

  def avatar_url
    image_attachments.first.try(:medium_url)
  end

end