module ProfileFieldsHelper

  def profile_field_span_tag( profile_field, options = { action: "show"} )
    render partial: 'shared/profile_field', object: profile_field
  end

#  def profile_field_show_value( profile_field )
#    profile_field.value
#  end


end
