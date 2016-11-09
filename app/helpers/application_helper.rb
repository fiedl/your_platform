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
    AppVersion.app_name
  end

  def app_name
    application_name
  end

  def asset_url(asset)
    "#{request.protocol}#{request.host_with_port}#{asset_path(asset)}"
  end

end
