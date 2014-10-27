class Philisterschaft < Group
  
  default_scope { philisterschaften }
  
end

class Group
  scope :philisterschaften, -> { where(name: ['Philisterschaft', 'Altherrenschaft']) }
end