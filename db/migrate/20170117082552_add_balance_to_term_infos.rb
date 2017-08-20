class AddBalanceToTermInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :term_infos, :balance, :integer
  end
end
