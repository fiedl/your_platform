class ProfileField < ActiveRecord::Base
  attr_accessible        :user_id, :label, :type, :value
end

class Custom < ProfileField

end

class Organisation < ProfileField

end

class Address < ProfileField

end

class Email < ProfileField

end
