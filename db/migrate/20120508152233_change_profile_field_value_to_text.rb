class ChangeProfileFieldValueToText < ActiveRecord::Migration

  def change
    change_table :profile_fields do |t|
      t.change :value, :text
    end
  end

end
