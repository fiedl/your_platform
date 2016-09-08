module BestInPlaceHelper

  def best_in_place_activator(activator_id, options = {class: 'best_in_place_activator do_not_show_in_edit_mode'})
    link_to(icon(:edit), '#', id: activator_id, class: options[:class])
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

end