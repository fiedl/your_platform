class Profile
  def initialize(profileable)
    @profileable = profileable
  end
  
  def profileable
    @profileable
  end
  
  def profile_fields
    @profileable.profile_fields
  end
  def fields
    profile_fields
  end
  
  def sections
    @profileable.profile_section_titles.collect do |title|
      section_by_title(title)
    end
  end

  def section_by_title(title)
    sections_by_title([title]).first
  end
  def sections_by_title(titles)
    titles.collect do |title|
      ProfileSection.new( title: title, profileable: @profileable )
    end
  end

end
