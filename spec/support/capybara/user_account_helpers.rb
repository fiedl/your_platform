module UserAccountHelpers
  def logged_in?
    has_link?(I18n.t(:logout))
  end

  def logged_out?
    has_no_link?(I18n.t(:logout))
  end

  def not_logged_in?
    logged_out?
  end
end

Capybara::Session.send(:include, UserAccountHelpers)
