# -*- coding: utf-8 -*-

# This extends the your_platform ProfileFIeld model.
require_dependency YourPlatform::Engine.root.join( 'app/models/profile_field' ).to_s

# This is the re-opened ProfileField class. All kinds of ProfileFields
# inherit from this class.
#
class ProfileField
  
  # List all possible types. This is needed for code injection security checks.
  #
  self.singleton_class.send :alias_method, :orig_possible_types, :possible_types
  def self.possible_types
    self.orig_possible_types + [
      ProfileFieldTypes::Study,
      ProfileFieldTypes::Klammerung
    ]
  end
  
end

