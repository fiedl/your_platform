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
        only: [:type, :key, :value, :created_at, :updated_at, :parent_id, :children],
        methods: [:key],
        include: {
          children: {
            only: [:type, :key, :value, :created_at, :updated_at, :parent_id],
            methods: [:key]
          },
          flags: {
            only: [:key, :created_at, :updated_at]
          }
        }
      },
      account: {
        only: [:created_at, :updated_at, :encrypted_password, :auth_token]
      }
    })
  end

  def backup_and_remove_profile(confirmation = {})
    backup_profile
    anonymize_name_and_remove_profile_and_account!(confirmation)
  end

  def restore_profile
    raise "This user (#{id}) already has an existing profile. Not restoring from backup file." if profile_fields.any?
    hash = ActiveSupport::JSON.decode(File.read(latest_backup_file))
    self.first_name = hash['first_name']
    self.last_name = hash['last_name']
    self.alias = hash['alias']
    self.save!
    hash['profile_fields'].each do |profile_field_hash|
      profile_field = self.profile_fields.create profile_field_hash.except('children', 'key', 'flags')
      profile_field.children.destroy_all # there might be relic children lying around
      profile_field.key = profile_field_hash['key']
      profile_field.save
      profile_field_hash['children'].each do |child_hash|
        profile_field.children.create child_hash.except('parent_id')
      end
      profile_field_hash['flags'].each do |flag_hash|
        profile_field.flags.create flag_hash
      end
    end
    self.delete_cache; self.reload  # to have `User#email` present
    account = self.build_account hash['account']
    account.password = Password.generate
    account.save!
    account.encrypted_password = hash['account']['encrypted_password']
    account.save!
    self.delete_cache
  end

  def anonymize_name_and_remove_profile_and_account!(confirmation = {})
    raise "Please confirm the destructive action by 'confirm: \"yes\"'." unless confirmation[:confirm] == "yes"
    self.profile_fields.destroy_all
    self.account.try(:destroy!)
    self.reload
    self.first_name = ""
    self.last_name = self.last_name.first
    self.email = nil
    self.alias = nil
    self.save!
  end

  def backup_path
    Rails.root.join('backups', self.class.storage_namespace, 'users')
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