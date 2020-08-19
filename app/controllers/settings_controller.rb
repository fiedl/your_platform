# This controller allows to change settings from the ui.
# See also: editable_setting.vue
#
class SettingsController < ApplicationController
  respond_to :json

  def update
    @setting = Setting.unscoped.find(params[:id])
    authorize! :manage_settings, @setting.thing

    @setting.value = new_value
    @setting.save!
    respond_with @setting
  end

  private

  def new_value
    value = params[:rails_settings_scoped_settings].try(:[], :value)
    value ||= params['rails_settings/settings'].try(:[], :value)
    value ||= params[:setting].try(:[], :value)
    value ||= params[:value]

    value = false if value == "false" or value == "0"
    value = true if value == "true" or value == "1"
    return value
  end

end