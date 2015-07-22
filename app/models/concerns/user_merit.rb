concern :UserMerit do
  
  def grant_badge(badge_name)
    badge_id = Merit::Badge.select { |badge| badge.name == badge_name }.first.id
    self.add_badge badge_id
  end
  
end