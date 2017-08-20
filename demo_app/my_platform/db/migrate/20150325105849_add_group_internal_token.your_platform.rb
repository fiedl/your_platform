# This migration comes from your_platform (originally 20120508201550)
class AddGroupInternalToken < ActiveRecord::Migration[4.2]

  def change

    change_table :groups do |t|
      t.string :internal_token
    end

  end

end
