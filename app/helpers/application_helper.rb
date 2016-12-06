module ApplicationHelper

  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self)
    if block_given?
      yield presenter
    else
      presenter.present()
    end
  end

  def application_name
    @application_name ||= if current_home_page.settings.app_name.present?
      current_home_page.settings.app_name
    else
      AppVersion.app_name
    end
  end

  def app_name
    application_name
  end

  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end

end
