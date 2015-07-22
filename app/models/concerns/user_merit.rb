concern :UserMerit do
  
  def grant_badge(badge_name)
    badge = Merit::Badge.select { |badge| badge.name == badge_name }.first
    self.add_badge badge.id unless self.badges.include? badge
  end
  
end