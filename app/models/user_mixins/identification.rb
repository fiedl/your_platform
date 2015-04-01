# This module extends the User class. Its purpose is to provide methods to identify a user using 
# a given login string. The user may identify himself using his:
# 
#   * first name plus last name
#   * last name only
#   * email address
#   * alias
#
module UserMixins::Identification

  extend ActiveSupport::Concern

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
      (
        User.where(alias: identification_string) +
        User.where(last_name: identification_string) +
        User.find_all_by_name(identification_string) +
        User.find_all_by_email(identification_string)
      ).uniq
    end

  end
end
