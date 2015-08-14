# This migration comes from your_platform (originally 20150729230344)
class AddTrigramToPostgres < ActiveRecord::Migration
  def up
    execute "create extension pg_trgm"
  end
  def down
    execute "drop extension pg_trgm"
  end
end
