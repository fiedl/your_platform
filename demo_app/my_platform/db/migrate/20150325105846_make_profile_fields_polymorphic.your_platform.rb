# This migration comes from your_platform (originally 20120507165551)
class MakeProfileFieldsPolymorphic < ActiveRecord::Migration[4.2]

  def change
    change_table :profile_fields do |t|
      # t.references :profileable, polymorphic: true
      t.rename :user_id, :profileable_id 
      t.string :profileable_type
    end
  end

end
