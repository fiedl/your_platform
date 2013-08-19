# This extends the your_platform profileable module.
require_dependency YourPlatform::Engine.root.join( 'app/models/profileable' ).to_s

module Profileable
  module InstanceMethodsForProfileables
    def profile_field_type_by_section(section)
      case section
        when :general
          super(section) + [ "ProfileFieldTypes::Klammerung" ]
        else
          super(section)
      end
    end
  end
end
