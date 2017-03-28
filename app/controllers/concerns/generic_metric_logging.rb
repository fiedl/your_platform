concern :GenericMetricLogging do

  included do
    helper_method :metric_logger

    # before_action :log_generic_metric_event
    after_action :log_request
    after_action  :log_activity
  end

  private

  # As we have deactivated the who-is-online feature,
  # we'll need a way to determine if we can safely
  # restart services.
  #
  # This model keeps track of user requests.
  # But we delete the user id later.
  #
  # Using the ip, which is stored, we try to identify
  # if several requests belong to a single visit.
  #
  def log_request
    if current_user
      Request.create user_id: current_user.id,
          ip: request.remote_ip,
          method: request.method,
          request_url: request.url,
          referer: request.referer,
          navable_id: current_navable.try(:id),
          navable_type: current_navable.try(:class).try(:name)
    end
  end

  # This logs the event using a metric storage.
  # Here, we use fnordmetric. The metrics can be viewed via
  #
  #   http://localhost:4242
  #
  # when the deamon is started via
  #
  #   bundle exec foreman start fnordmetric
  #
  def log_generic_metric_event
    unless read_only_mode?
      type = "#{self.class.name.underscore}_#{action_name}"  # e.g. pages_controller_show
      metric_logger.log_event( { id: params[:id] }, type: type)
      metric_logger.log_event( { request_type: type }, type: :generic_request)
    end
  end
  def metric_logger
    @metric_logger ||= MetricLogger.new(current_user: current_user, session_id: session[:session_id])
  end


  # Generic Activity Logger
  #
  def log_activity
    if not read_only_mode? and not action_name.in?(["index", "show", "download", "autocomplete_title", "preview", "description"]) and not params['controller'].in?(['sessions', 'devise/sessions', 'profile_fields', 'user_accounts'])
      begin
        type = self.class.name.gsub("Controller", "").singularize
        id = params[:id]
        object = type.constantize.find(id)
      rescue
        # there is no object associated, e.g. for the RootController
      end

      PublicActivity::Activity.create!(
        trackable: object,
        key: action_name,
        owner: current_user,
        parameters: params.except('authenticity_token', 'attachment', 'message').deep_merge({
          "user" => {avatar: nil},
          "user_account" => {password: nil, password_confirmation: nil}
        })
      )
    end
  end

end