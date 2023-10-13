class AddGroupInternalToken < ActiveRecord::Migration[4.2]

  def change

    change_table :groups do |t|
      t.string :internal_token
    end

  end

end
