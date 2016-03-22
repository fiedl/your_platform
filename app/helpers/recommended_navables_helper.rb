module RecommendedNavablesHelper
  
  def recommended_navables
    @recommended_navables ||= if current_user && current_navable && (not current_user.incognito?)
      track_visit
      Rails.cache.fetch([current_user, "recommended_navables"], expires_in: 5.minutes) do
        current_user.recommended_navables - HorizontalNav.for_user(current_user, current_navable: current_navable).navables
      end - [current_navable]
    else
      []
    end
  end
  
  def track_visit
    current_user.track_visit current_navable
  end
end