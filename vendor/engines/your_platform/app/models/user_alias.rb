# The UserAlias is a String that is used for identification during login.
# It can be chosen by the user and defaults to a combination of first and last name.
# The alias is unique, i.e. two users can't have the same alias.
#
#    UserAlias.taken?("foo")
#    alias = user.generate_alias
#    alias = UserAlias.generate_for(user)
#
class UserAlias < String
  
  # UserAlias.taken? "foo"  # => false
  # User.create(alias: "foo", ...)
  # UserAlias.taken? "foo"  # => <User ...>
  #
  def self.taken?( alias_to_check )
    User.where( :alias => alias_to_check ).try(:first) || false
  end

  # Checks if the alias is already taken by a User stored in the database.
  #
  #    user = User.new(alias: "foo")
  #    user.alias.taken?  # => false
  #    user.save
  #    user.alias.taken?  # => <User ...>
  #
  def taken?
    UserAlias.taken? self
  end
  
  # Generate an alias for a User based on the user's name.
  # 
  #     user.alias = UserAlias.generate_for(user)
  #     user.generate_alias
  #
  def self.generate_for(user)
    raise 'no user given' if not user
    raise 'the given user has no last_name' if not user.last_name.present?
    raise 'the given user has no first_name' if not user.first_name.present?
    
    suggestion = try_to_generate_from_last_name(user)                      # doe
    suggestion ||= try_to_generate_from_first_and_last_name(user)          # j.doe
    suggestion ||= try_to_generate_long_from_first_and_last_name(user)     # john.doe
    suggestion ||= try_to_generate_long_from_name_and_year_of_birth(user)  # john.doe.1986
    
    # If the suggestion is still empty (no successful generation), the empty 
    # alias will raise a validation error and the user will be asked to enter
    # an alias.
    
    return UserAlias.new(suggestion) if suggestion
    return nil
  end
  
  private
  
  # If there is no other user having the same last name, use just the last name
  # as alias.
  #
  def self.try_to_generate_from_last_name(user)

    # TODO: Rails 4 way: User.where(...).where.not(...)
    # http://stackoverflow.com/questions/5426421/rails-model-find-where-not-equal
    
    if User.where("last_name=? AND id!=?", user.last_name, user.id).count == 0
      user.last_name.downcase
    end
  end
  
  # If there is no other user with the same last name and the same initial of the
  # first name, use a combination like j.doe as alias.
  #
  def self.try_to_generate_from_first_and_last_name(user)
    if User.where("last_name=? 
                   AND first_name LIKE ?
                   AND id!=?", 
                   user.last_name, "#{user.first_name.first}%", user.id ).count == 0
      "#{user.first_name.downcase.first}.#{user.last_name.downcase}"
    end
  end
  
  # If there is no other user with the same first and last name, use
  # a combination like john.doe as alias.
  #
  def self.try_to_generate_long_from_first_and_last_name(user)
    if User.where("last_name=? 
                   AND first_name=? 
                   AND id!=?", 
                   user.last_name, user.first_name, user.id ).count == 0
      "#{user.first_name.downcase}.#{user.last_name.downcase}"
    end
  end
  
  # If there is no other user with the same first name, last name and
  # year of birth, use a combination like john.doe.1986 as alias.
  #
  def self.try_to_generate_long_from_name_and_year_of_birth(user)
    if user.date_of_birth
      if User.where("last_name=? 
                     AND first_name=? 
                     AND id!=?", 
                     user.last_name, user.first_name, user.id ).select do |other_user|
                       other_user.date_of_birth && 
                         (other_user.date_of_birth.year != user.date_of_birth.year)
                     end.count == 0
        "#{user.first_name.downcase}.#{user.last_name.downcase}.#{user.date_of_birth.year}"
      end
    end
  end  

end



