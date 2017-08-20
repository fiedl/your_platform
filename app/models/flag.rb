class Flag < ApplicationRecord

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
