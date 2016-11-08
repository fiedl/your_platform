module BestInPlaceHelper

  def best_in_place_activator(activator_id, options = {class: 'best_in_place_activator do_not_show_in_edit_mode'})
    link_to(icon(:edit), '#', id: activator_id, class: options[:class])
  end

  # For example:
  #
  #   setting_in_place @page, :layout
  #
  def setting_in_place(object, setting_key, options = {})
    setting = object.settings.where(var: setting_key).first_or_create
    best_in_place setting, :value, options
  end

  def setting_in_place_if(condition, object, setting_key, options = {})
    if condition
      setting_in_place object, setting_key, options
    else
      object.settings.send setting_key
    end
  end

  def ajax_check_box(object, attribute, label = nil)
    label ||= I18n.t(attribute)
    form_for object, remote: true do |f|
      content_tag :label do
        f.hidden_field(attribute, value: false) +
        f.check_box(attribute, {class: 'ajax_check_box'}, true) +
        label
      end
    end
  end

  def setting_check_box(object, setting_key, label = nil)
    label ||= I18n.t(setting_key)
    setting = object.settings.where(var: setting_key).first_or_create
    ajax_check_box setting, :value, label
  end

end