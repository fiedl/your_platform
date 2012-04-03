class User < ActiveRecord::Base
  # attr_accessible :title, :body

  def name
    first_name + " " + last_name 
  end

  def profile_fields
    ProfileField.find(:all, :conditions => "user_id = '#{id}'")
  end

end
