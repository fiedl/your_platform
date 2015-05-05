# This migration comes from your_platform (originally 20120508152233)
class ChangeProfileFieldValueToText < ActiveRecord::Migration

  def change
    change_table :profile_fields do |t|
      t.change :value, :text
    end
  end

end
