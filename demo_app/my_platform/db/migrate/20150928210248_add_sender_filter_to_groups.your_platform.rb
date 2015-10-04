# This migration comes from your_platform (originally 20150928165027)
class AddSenderFilterToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :mailing_list_sender_filter, :string
  end
end
