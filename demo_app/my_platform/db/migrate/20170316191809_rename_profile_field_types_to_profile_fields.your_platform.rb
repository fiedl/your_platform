# This migration comes from your_platform (originally 20170316191356)
class RenameProfileFieldTypesToProfileFields < ActiveRecord::Migration
  def change
    %w(About AcademicDegree Address BankAccount Competence Custom Date Description Email Employment General Homepage MailingListEmail NameSurrounding Organization Phone ProfessionalCategory Study).each do |sub_type|
      rename_sti_type :profile_fields, "ProfileFieldTypes::#{sub_type}", "ProfileFields::#{sub_type}"
    end
  end

  # http://stackoverflow.com/a/31762672/2066546
  def rename_sti_type(table_name, old_type, new_type)
    reversible do |dir|
      dir.up { execute "UPDATE #{table_name} SET type = '#{new_type}' WHERE type = '#{old_type}'" }
      dir.down { execute "UPDATE #{table_name} SET type = '#{old_type}' WHERE type = '#{new_type}'"}
    end
  end
end
