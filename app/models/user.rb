class User < ActiveRecord::Base
  # attr_accessible :title, :body
  # validates_presence_of    :first_name

  def name
    first_name + " " + last_name 
  end

  def email
    email_profile_field.value
  end
  def email=(email)
    pf = email_profile_field
    pf.value = email
    pf.save
  end

  def profile_fields
    ProfileField.find( :all, :conditions => "user_id = '#{id}'" )
  end

  private

  def email_profile_field
    ProfileField.find( :first, :conditions => "user_id='#{id}' AND type='Email'" )
  end

end
