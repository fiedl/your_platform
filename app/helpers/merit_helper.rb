module MeritHelper
  def merit_indicator(user)
    (merit_points(user) + " " + bronce_badges(user)).html_safe if show_merit_indicators?
  end
  
  def merit_points(user)
    content_tag :span, class: :merit_points do
      user.points.to_s.html_safe
    end.html_safe
  end
  
  def bronce_badges(user)
    merit_badges(user, :bronce)
  end
  
  def silver_badges(user)
    merit_badges(user, :silver)
  end
  
  def gold_badges(user)
    merit_badges(user, :gold)
  end
  
  def merit_badges(user, difficulty)
    count = user.badges.select { |badge| badge.custom_fields[:difficulty] == difficulty }.count
    return (count.to_s + medal_icon(difficulty)).html_safe if count > 0
  end
  
  def medal_icon(difficulty)
    "<span class='#{difficulty} medal'>●</span>".html_safe
  end
  
  def badge_label(badge)
    difficulty = badge.custom_fields[:difficulty]
    link_to badge_path(id: badge.id) do
      content_tag :span, class: 'label badge-label' do
        medal_icon(difficulty) + badge.name
      end.html_safe
    end
  end
  
  def badge_check_icon
    content_tag :span, class: 'green badge_check' do
      awesome_icon :check
    end.html_safe
  end
  
  def show_merit_indicators?
    # TODO: Remove this temporary blocking mechanism:
    current_user.id <= 2 || Rails.env.development?
  end
    
end