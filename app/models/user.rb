class User < ActiveRecord::Base
  # attr_accessible :title, :body

  def name
    first_name + " " + last_name 
  end

end
