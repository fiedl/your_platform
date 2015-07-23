concern :UserMerit do
  
  def grant_badge(badge_name)
    badge = Merit::Badge.select { |badge| badge.name == badge_name }.first
    unless self.badges.include? badge
      self.add_badge badge.id 
      # ReputationChangeObserver.new.update({
      #   description: "#{self.title} has earned the #{badge_name} badge.",
      #   sash_id: self.sash_id,
      #   granted_at: Time.zone.now
      # })
    end
  end
  
end