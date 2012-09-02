class MakeProfileFieldsPolymorphic < ActiveRecord::Migration

  def change
    change_table :profile_fields do |t|
      # t.references :profileable, polymorphic: true
      t.rename :user_id, :profileable_id 
      t.string :profileable_type
    end
    
    ProfileField.reset_column_information
    ProfileField.all.each do |pf|
      pf.profileable_type = "User"  # Before that point in the migration chain, only users had profile_fields.
      pf.save
    end
  end

end
