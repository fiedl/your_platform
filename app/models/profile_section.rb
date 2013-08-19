
# This extends the your_platform ProfileSection model.
require_dependency YourPlatform::Engine.root.join( 'app/models/profile_section' ).to_s

class ProfileSection
  
  alias_method :orig_profile_field_types, :profile_field_types
  def profile_field_types
    case(self.title.to_sym)
      when :general
        orig_profile_field_types + [ "ProfileFieldTypes::Klammerung" ]
      else
        orig_profile_field_types
    end
  end
end  
