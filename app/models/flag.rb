class Flag < ActiveRecord::Base
  attr_accessible :flagable_id, :flagable_type, :key if defined? attr_accessible

  belongs_to :flagable, polymorphic: true

  def to_sym
    key.to_sym
  end

  def to_s
    key.to_s
  end

  def inspect
    to_sym
  end

end
