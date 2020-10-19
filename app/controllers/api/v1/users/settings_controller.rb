class Api::V1::Users::SettingsController < Api::V1::BaseController

  expose :user, -> { User.find params[:user_id] }
  expose :key, -> { params[:key] if params[:key].to_sym.in? permitted_keys}
  expose :value, -> { params[:value] }

  def update
    authorize! :update, user
    raise "no valid settings key: #{key}" if key.blank? or not key.to_sym.in?(permitted_keys)

    user.settings.send("#{key}=", value)
    user.touch
  end

  private

  def permitted_keys
    [:dark_mode, :show_ribbon]
  end

end