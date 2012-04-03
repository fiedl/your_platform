class ProfileField < ActiveRecord::Base
  # attr_accessible :title, :body
end

class Custom < ProfileField

end

class Organisation < ProfileField

end

class Address < ProfileField

end
