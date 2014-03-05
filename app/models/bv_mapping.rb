class BvMapping < ActiveRecord::Base
  attr_accessible :bv_name, :plz
  
  def self.find_or_create(args)
    self.find_by_plz(args[:plz]) || self.create(args)
  end
end
