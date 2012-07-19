module ProfileableHelper
  
  def profile_sections_for_profileable( profileable, sections = [] )
    sections.collect do |section|
      profile_section_html( profileable, section ) #if profileable.profile_fields_by_section( section ).count > 0
    end.join.html_safe
  end

  private
  
  def profile_section_html( profileable, section )
    [ content_tag( :h1, t( section ) ),
      content_tag( :div ) do
        c = ""
        if section.to_sym == :contact_information 
          if profileable.profile_fields_by_type( "Address" ).count > 0
            c += map_of_address_profile_fields( profileable.profile_fields_by_type( "Address" ) ) 
          end
        end
        c += content_tag( :dl ) do
          if profileable.profile_fields_by_section( section )
            profileable.profile_fields_by_section( section ).collect do |pf|
              profile_field_html pf
            end.join.html_safe
          end
        end
        c.html_safe
      end
    ].join.html_safe
  end

  def profile_field_html( profile_field )
    profile_field_span_tag( profile_field )
  end

  def map_of_address_profile_fields( address_profile_fields )
    json = address_profile_fields.to_gmaps4rails
    gmaps4rails( json ) if json
  end
  
end
