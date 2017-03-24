concern :EventGroups do

  included do
    belongs_to :group
  end

  def self.move_event_to_group(event_id, group_id)
    Event.find(event_id).move_to Group.find(group_id)
  end

  def move_to(group)
    self.group_id = group.id
    self.save
  end

  class_methods do
    def find_all_by_group(group)
      group.events_of_self_and_subgroups.order('start_at')
    end

    def find_all_by_groups(groups)
      self.where(id: groups.map(&:event_ids_of_self_and_subgroups).flatten.uniq).order('start_at')
    end
  end
end