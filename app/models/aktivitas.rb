class Aktivitas < Group
  
  default_scope { aktivitates }

end

class Group
  scope :aktivitates, -> { where(name: ['Aktivitas', 'Activitas']) }
end