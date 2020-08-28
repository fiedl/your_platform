concern :PrivateViews do

  included do
    before_action :prepend_private_views
  end

  def prepend_private_views
    prepend_view_path private_views_path if File.exists? private_views_path
  end

  private

  def private_views_repo_path
    Rails.application.root.join('lib/your_platform_private_additions').to_s
  end

  def private_views_path
    "#{private_views_repo_path}/views"
  end

end