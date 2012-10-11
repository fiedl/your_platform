class AddErstbandphilisterGroups < ActiveRecord::Migration
  def up
    Group.create_erstbandphilister_parent_groups
  end

  def down
    Group.find_by_flag( :erstbandphilister_parent_group ).each do |group|
      group.destroy
    end
  end
end
