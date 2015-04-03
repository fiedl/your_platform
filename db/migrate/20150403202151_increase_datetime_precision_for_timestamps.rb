# In order to handle cache_keys properly, we need to store timestamps
# with µs precision.
#
# Trello: https://trello.com/c/jh6CpwdX/811-caching-zeit-auflosung
# 
# Gist: https://gist.github.com/iamatypeofwalrus/d074d22a736d49459b15
#
class IncreaseDatetimePrecisionForTimestamps < ActiveRecord::Migration
  # Include non default date stamps here
  # Key   :table_name
  # value [:column_names]
  # NOTE: only MySQL 5.6.4 and above supports DATETIME's with more precision than a second.
  TABLES_AND_COLUMNS = {
    users: [:created_at, :updated_at],
    groups: [:created_at, :updated_at],
    dag_links: [:created_at, :updated_at],
    profile_fields: [:created_at, :updated_at],
    pages: [:created_at, :updated_at]
  }
  
  def up
    TABLES_AND_COLUMNS.each do |table, columns|
      columns.each do |column|
        # MySQL supports time precision down to microseconds -- DATETIME(6)
        change_column table, column, :datetime, limit: 6
      end
    end
  end
 
  def down
    TABLES_AND_COLUMNS.each do |table, columns|
      columns.each do |column|
        echange_column table, column, :datetime
      end
    end
  end
end