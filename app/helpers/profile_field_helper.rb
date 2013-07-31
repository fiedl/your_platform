module ProfileFieldHelper
  
  # args:
  #   profileable
  #   profile_field_type
  #   profile_section
  #
  def link_to_add_profile_field( args )
    raise "expected argument 'profileable'" unless args[:profileable].present?
    raise "expected argument 'profile_field_type'" unless args[:profile_field_type].present?
    raise "expected argument 'profile_section'" unless args[:profile_section].present?        
    link_to( I18n.t(args[:profile_field_type].demodulize.underscore),
             url_for( :controller => :profile_fields,
                      :profileable_id => args[:profileable].id,
                      :profileable_type => args[:profileable].class.name,
                      :profile_field => {:type => args[:profile_field_type]},
                      :section => args[:profile_section]
                    ),
             :id => "add_#{args[:profile_field_type].demodulize.underscore}_field",
             :remote => true,
             :method => 'post'
           )
  end
end
