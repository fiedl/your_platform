# This migration comes from your_platform (originally 20170114210654)
class CreateTermInfos < ActiveRecord::Migration[4.2]
  def change
    create_table :term_infos do |t|
      t.integer :term_id
      t.integer :corporation_id
      t.integer :number_of_members
      t.integer :number_of_new_members
      t.integer :number_of_membership_ends
      t.integer :number_of_deaths
      t.integer :number_of_events

      t.timestamps null: false
    end
  end
end
