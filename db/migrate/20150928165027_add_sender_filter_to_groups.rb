class AddSenderFilterToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :mailing_list_sender_filter, :string
  end
end
