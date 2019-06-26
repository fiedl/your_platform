concern :UserBackup do

  def backup_profile
    FileUtils.mkdir_p backup_path
    File.open(backup_file, "w") do |f|
      f.write as_json_for_backup.to_json
    end
  end

  def as_json_for_backup
    as_json(include: {
      profile_fields: {
        only: [:type, :label, :value, :created_at, :updated_at, :parent_id],
        includes: {
          children: {
            only: [:type, :label, :value, :created_at, :updated_at, :parent_id]
          }
        }
      }
    })
  end

  def backup_and_remove_profile(confirmation = {})
    backup_profile
    anonymize_name_and_remove_profile_and_account!(confirmation)
  end

  def restore_profile
    raise "This user (#{id}) already has an existing profile. Not restoring from backup file." if profile_fields.any?

  end

  def anonymize_name_and_remove_profile_and_account!(confirmation = {})
    raise "Please confirm the destructive action by 'confirm: \"yes\"'." unless confirmation[:confirm] == "yes"
    self.first_name = ""
    self.last_name = self.last_name.first
    self.save
    self.profile_fields.destroy_all
    self.account.try(:destroy)
  end

  def backup_path
    Rails.root.join('backups', 'users')
  end

  def backup_file
    File.join backup_path, "#{id}-#{title.parameterize}-#{Time.zone.now.to_s.parameterize}.json"
  end

  def backup_files
    Dir.glob(File.join(backup_path, "#{id}-*")).sort
  end

  def latest_backup_file
    backup_files.last
  end

end