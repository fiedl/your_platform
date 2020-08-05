module EditableHelper

  # Usage:
  #
  #   editable user, :email, type: "email"
  #
  def editable(object, key, type: 'text', editable: nil, placeholder: nil, class: nil, input_class: nil)
    content_tag "vue-editable", "", {
      parameter: "#{object.class.name.parameterize}_#{object.id}",
      'initial-value': object.send(key),
      type: type,
      url: url_for(object),
      'param-key': "#{object.class.model_name.param_key}[#{key}]",
      ':editable': editable.nil? ? can?(:update, object) : editable,
      placeholder: placeholder,
      input_class: binding.local_variable_get(:class) || input_class
    }
  end

  def editable_profile_field(profile_field, type: 'text')
    content_tag "vue-editable-property", "", {
      property: "profile_field_#{profile_field.id}",
      'initial-value': profile_field.value,
      'initial-label': profile_field.label,
      type: type,
      editable: can?(:update, profile_field),
      url: profile_field_path(profile_field),
      'value-param-key': "profile_field[value]",
      'label-param-key': "profile_field[label]"
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