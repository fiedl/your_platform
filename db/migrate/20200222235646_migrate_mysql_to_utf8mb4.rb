class MigrateMysqlToUtf8mb4 < ActiveRecord::Migration[5.0]
  # https://gist.github.com/amuntasim/f3b12f20a30e9a9f3fb0

  def change
    alter_database_and_tables_charsets "utf8mb4", "utf8mb4_bin"
  end

  private

  def alter_database_and_tables_charsets(charset = default_charset, collation = default_collation)
    case connection.adapter_name
    when 'Mysql2'
      execute "ALTER DATABASE #{connection.current_database} CHARACTER SET #{charset} COLLATE #{collation}"

      connection.data_sources.each do |table|
        execute "ALTER TABLE #{table} CONVERT TO CHARACTER SET #{charset} COLLATE #{collation}"
      end
    else
      # OK, not quite irreversible but can't be done if there's not
      # the code here to support it...
      raise ActiveRecord::IrreversibleMigration.new("Migration error: Unsupported database for migration to UTF-8 support")
    end
  end

  def default_charset
    case connection.adapter_name
      when 'Mysql2'
        execute("show variables like 'character_set_server'").fetch_hash['Value']
      else
        nil
    end
  end

  def default_collation
    case connection.adapter_name
      when 'Mysql2'
        execute("show variables like 'collation_server'").fetch_hash['Value']
      else
        nil
    end
  end

  def connection
    ActiveRecord::Base.connection
  end
end
