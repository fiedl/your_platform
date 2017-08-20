class AddSenderFilterToGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :mailing_list_sender_filter, :string
  end
end
