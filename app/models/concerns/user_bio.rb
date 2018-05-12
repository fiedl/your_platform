concern :UserBio do

  def bio
    profile_fields.where(type: "ProfileFields::About").first.try(:value).to_s
  end

  def bio=(new_text)
    pf = profile_fields.where(type: "ProfileFields::About").first_or_create
    pf.value = new_text
    pf.save
  end

end