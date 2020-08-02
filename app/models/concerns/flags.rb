concern :Flags do

  included do
    has_many :flags, :as => :flagable, :dependent => :destroy

    scope :flagged, lambda { |flag| includes(:flags).where(flags: {key: flag}) }
    scope :not_flagged, lambda { |flags|
      group_ids_other_flags = includes(:flags).where.not(flags: {key: flags}).pluck(:id)
      group_ids_no_flags = includes(:flags).where(flags: {flagable_id: nil})
      where(id: group_ids_other_flags + group_ids_no_flags)
    }

    scope :has_flags, -> { where.not(flags: {id: nil}) }
    scope :has_no_flags, -> { where(flags: {id: nil}) }
  end

  class_methods do
    def find_all_by_flag(flag)
      self.joins(:flags).where(flags: {key: flag})
    end

    def find_by_flag(flag)
      find_all_by_flag(flag).limit(1).readonly(false).first
    end

    def find_or_create_by_flag(flag)
      find_by_flag(flag) || create_by_flag(flag)
    end

    def create_by_flag(flag)
      obj = self.create
      obj.add_flag flag
      return obj
    end
  end

  def add_flags(*new_flags)
    if new_flags.kind_of? Array
      for new_flag in new_flags
        if new_flag.kind_of? String or new_flag.kind_of? Symbol
          if not self.has_flag? new_flag
            self.flags.create(key: new_flag.to_sym)
          end
        end
      end
    end
  end

  def add_flag(new_flag)
    self.add_flags new_flag
  end

  def remove_flags(*flags_to_remove)
    self.flags.where(key: flags_to_remove).destroy_all
  end

  def remove_flag(flag_to_remove)
    self.remove_flags flag_to_remove
  end

  def flags_to_syms
    self.flags.pluck(:key).map(&:to_sym)
  end

  def has_flag?(flag)
    self.flags_to_syms.include? flag
  end

end
