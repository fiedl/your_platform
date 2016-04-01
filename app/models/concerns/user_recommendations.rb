concern :UserRecommendations do
  
  def track_visit(navable)
    self.group_ids.each do |group_id|
      NavableVisit.create group_id: group_id, navable: navable
    end
  end
  
  def recommended_navables
    NavableVisit
      .where(group_id: self.group_ids)
      .group(:navable_type, :navable_id)
      .order('count_id desc').count('id')
      .take(10)
      .collect { |type_and_id_and_count| # [[type, id], count] 
        type_and_id_and_count.first.first.constantize.find(type_and_id_and_count.first.last)
      }.select { |navable| 
        self.can? :read, navable
      }
  end
  
end