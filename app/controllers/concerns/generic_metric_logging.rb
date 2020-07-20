concern :GenericMetricLogging do

  included do
    # after_action :log_request
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
    if current_user && (not read_only_mode?)
      Request.create user_id: current_user.id,
          ip: request.remote_ip,
          method: request.method,
          request_url: request.url.to_s.first(250),
          referer: request.referer.to_s.first(250),
          navable_id: current_navable.try(:id),
          navable_type: current_navable.try(:class).try(:name)
    end
  end


  # Generic Activity Logger
  #
  def log_activity
    if not read_only_mode? and not action_name.in?(["index", "show", "download", "autocomplete_title", "preview", "description"]) and not params['controller'].in?(['sessions', 'devise/sessions', 'api/v1/sessions', 'profile_fields', 'user_accounts'])
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
        parameters: params.to_unsafe_hash.except('authenticity_token', 'attachment', 'message').deep_merge({
          "password" => nil,
          "password_confirmation" => nil,
          "user" => {avatar: nil},
          "user_account" => {password: nil, password_confirmation: nil},
          "session" => {password: nil}
        })
      )
    end
  end

end