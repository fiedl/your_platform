# This migration comes from your_platform (originally 20150928165027)
class AddSenderFilterToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :mailing_list_sender_filter, :string
  end
end
