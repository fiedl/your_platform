module BestInPlaceHelper

  def best_in_place_activator(activator_id, options = {class: 'best_in_place_activator do_not_show_in_edit_mode'})
    link_to(icon(:edit), '#', id: activator_id, class: options[:class])
  end

  def ajax_check_box(object, attribute, label)
    form_for object, remote: true do |f|
      f.label attribute do
        f.hidden_field(attribute, value: false) +
        f.check_box(attribute, {class: 'ajax_check_box'}, true) +
        label
      end
    end
  end

  def wysiwyg_in_place(object, attribute, options = {})
    wysiwyg_in_place_if(true, object, attribute, options)
  end

  def wysiwyg_in_place_if(condition, object, attribute, options = {})
    options[:toolbar] ||= false
    options[:multiline] ||= false
    options[:activate] = 'click' if options[:activate].nil?

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