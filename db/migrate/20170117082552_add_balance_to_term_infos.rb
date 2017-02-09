class AddBalanceToTermInfos < ActiveRecord::Migration
  def change
    add_column :term_infos, :balance, :integer
  end
end
