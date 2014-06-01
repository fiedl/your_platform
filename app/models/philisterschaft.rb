class Philisterschaft < Group
  
  scope :philisterschaften, -> { where(name: ['Philisterschaft', 'Altherrenschaft']) }
  default_scope { philisterschaften }
  
end