class Aktivitas < Group
  
  scope :aktivitates, -> { where(name: ['Aktivitas', 'Activitas']) }
  default_scope { aktivitates }
  
end