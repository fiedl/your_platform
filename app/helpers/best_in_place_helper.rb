module BestInPlaceHelper

  def best_in_place_activator(activator_id, options = {class: 'best_in_place_activator do_not_show_in_edit_mode'})
    link_to(icon(:edit), '#', id: activator_id, class: options[:class])
  end

  # For example:
  #
  #   setting_in_place @page, :layout
  #
  def setting_in_place(object, setting_key, options = nil)
    setting = object.settings.where(var: setting_key).first_or_create
    best_in_place setting, :value
  end

  def ajax_check_box(object, attribute, label = nil)
    label ||= I18n.t(attribute)
    form_for object, remote: true do |f|
      f.label attribute do
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

  # Use for attributes:
  #
  #    wysiwyg_in_place page, :content, multiline: true, toolbar: true
  #
  # Use for settings:
  #
  #    wysiwyg_in_place page, nil, setting: :home_page_sub_title
  #
  def wysiwyg_in_place(object, attribute, options = {})
    wysiwyg_in_place_if(true, object, attribute, options)
  end

  def wysiwyg_in_place_if(condition, object, attribute, options = {})
    options[:toolbar] ||= false
    options[:multiline] ||= false
    options[:activate] = 'click' if options[:activate].nil?

    if attribute.nil? and options[:setting]
      setting = object.settings.where(var: options[:setting]).first_or_create
      object = setting; attribute = :value
    end

    ((options[:toolbar] && condition) ? render(partial: 'shared/wysiwyg_toolbar') : '').html_safe +
    content_tag(:div, id: "edit-#{object.class.name.underscore}-#{object.id}", class: "#{condition ? 'wysiwyg editable' : ''} #{options[:multiline] ? 'multiline' : ''}", data: {url: object.url, object_key: object.class.base_class.name.underscore, attribute_key: attribute, activate: options[:activate]}) do
      if block_given?
        yield
      else
        h(object.send(attribute))
      end
    end.html_safe
  end

end