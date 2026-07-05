class ChangeProfileFieldValueToText < ActiveRecord::Migration[4.2]

  def change
    change_table :profile_fields do |t|
      t.change :value, :text
    end
  end

end
