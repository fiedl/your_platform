module EditableHelper

  # Usage:
  #
  #   editable user, :email, type: "email"
  #
  def editable(object, key, type: 'text', editable: nil, placeholder: nil, class: nil, input_class: nil)
    if type == 'date'
      initial_value = localize object.send(key).to_date if object.send(key)
    elsif type == 'datetime'
      initial_value = localize object.send(key) if object.send(key)
    else
      initial_value = object.send(key)
    end
    content_tag "vue-editable", "", {
      parameter: "#{object.class.name.parameterize}_#{object.id}",
      'initial-value': initial_value,
      type: type,
      url: url_for(object),
      'param-key': "#{object.class.model_name.param_key}[#{key}]",
      ':editable': editable.nil? ? can?(:update, object) : editable,
      placeholder: placeholder,
      input_class: binding.local_variable_get(:class) || input_class
    }
  end

  def editable_profile_field(profile_field, hide_label: false)
    content_tag "vue_profile_field", "", {
      ':initial-profile-field': profile_field.as_json.merge({
        editable: can?(:update, profile_field)
      }).to_json,
      ':hide_label': hide_label.to_json
    }
  end

  def editable_profile_fields(profileable:, types: [], profile_fields: [], new_profile_fields: [])
    profile_fields = profileable.profile_fields.where(type: types) unless profile_fields.present?
    profile_fields = profile_fields
      .collect { |profile_field| profile_field.as_json.merge({editable: can?(:update, profile_field)})}
      .to_json
    content_tag "vue-profile-fields", "", {
      ':initial_profile_fields': profile_fields,
      ':new_profile_fields': new_profile_fields.to_json,
      ':profile_field_types': types.to_json,
      profileable_id: profileable.id,
      profileable_type: profileable.class.base_class.name,
      ':editable': can?(:update, profileable)
    }
  end

end