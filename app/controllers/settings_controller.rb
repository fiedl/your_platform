# This controller allows to change settings from the ui,
# for example, with best_in_place, like this:
#
#     best_in_place page.settings, :layout
#
class SettingsController < ApplicationController
  respond_to :json

  def update
    @setting = Setting.unscoped.find(params[:id])
    authorize! :manage, @setting.thing

    @setting.value = new_value
    @setting.save!
    respond_with @setting
  end

  private

  def new_value
    value = params[:rails_settings_scoped_settings].try(:[], :value)
    value ||= params['rails_settings/settings'].try(:[], :value)
    value ||= params[:setting].try(:[], :value)
    value = false if value == "false" or value == "0"
    value = true if value == "true" or value == "1"
    return value
  end

end