module GroupMixins::SpecialGroups::HasSpecialChildParentGroup

  # Each group can have certain sub-groups, e.g. for officers or guests.
  # This method creates a couple of instance methods to interact with
  # these special sub-groups.
  #
  # For example, call:
  # 
  #   class Group
  #     ...
  #     extend HasSpecialChildParentGroup
  #     ...
  #     has_special_child_parent_group :officers
  #     has_special_child_parent_group :guests
  #     ...
  #   end
  #   
  # This would create the following instance methods for each group.
  #
  #   officers_parent
  #   officers_parent!
  #   officers
  #   find_officers_parent_group
  #   create_officers_parent_group
  #   find_officers_groups
  #   guests_parent
  #   guests_parent!
  #   guests
  #   find_geusts_parent_group
  #   create_guests_parent_group
  #   find_guests_groups
  # 
  def has_special_child_parent_group( parent_for ) # e.g. for :officers or :guests                                                  
    self.class_eval <<-EOL

        def #{parent_for}_parent # e.g. officers_parent
          self.find_#{parent_for}_parent_group
        end                                                                                                                          

        def #{parent_for}_parent! # e.g. officers_parent!
          self.create_#{parent_for}_parent_group
        end

        def #{parent_for} # e.g. officers
          self.find_#{parent_for}_groups
        end                                                                                                                          
        
        def find_#{parent_for}_parent_group # e.g. find_officers_parent_group
          self.child_groups.find_by_flag( :#{parent_for}_parent ) unless self.has_flag? :#{parent_for}_parent
        end

        def create_#{parent_for}_parent_group # e.g. create_officers_parent_group
          unless self.has_flag? :#{parent_for}_parent
            #{parent_for}_parent = self.#{parent_for}_parent
            unless self.#{parent_for}_parent
              #{parent_for}_parent = Group.create( name: I18n.translate( :#{parent_for}_parent ) )
              #{parent_for}_parent.parent_groups << self
              #{parent_for}_parent.add_flag( :#{parent_for}_parent )
            end
            return #{parent_for}_parent
          end
        end
      
        def find_#{parent_for}_groups # e.g. find_officers_groups
          self.find_#{parent_for}_parent_group.descendant_groups
        end

    EOL

  end
end
