# -*- coding: utf-8 -*-

# This module extends the User class. Its purpose is to provide methods to identify a user using 
# a given login string. The user may identify himself using his first name plus last name, his last name only, his 
# email address or his alias, as long as the identifyer is unique.
#
module UserMixins::Identification

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

    # The user may identify himself using one of these attributes.
    #
    def attributes_used_for_identification
      [ :alias, :last_name, :name, :email ]
    end

    # Find all users where the identification string matches one of the attributes
    # given by `attributes_used_for_identification`.
    #
    # This method returns an array of users matching the given login string.
    # In contrast to `self.identify`, this returns an array, whereas `self.identify`
    # returns a user object if the match was unique.
    #
    def find_all_by_identification_string( identification_string )
      self.attributes_used_for_identification.collect do |attribute_name|
        self.send( "find_all_by_#{attribute_name}".to_sym, identification_string )
      end.flatten.uniq
    end

  end
end
