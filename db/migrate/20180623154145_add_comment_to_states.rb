class AddCommentToStates < ActiveRecord::Migration[5.0]
  def change
    add_column :states, :comment, :text
  end
end
