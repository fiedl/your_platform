Refile.mount_point = '/refile'
Refile.automount = false

Refile.store = Refile::Backend::FileSystem.new(Rails.root.join("uploads/refile/store").to_s)
Refile.cache = Refile::Backend::FileSystem.new(Rails.root.join("uploads/refile/cache").to_s)

Refile.host = Rails.configuration.asset_host if Rails.configuration.asset_host.present?

# Add in missing methods for file uploads in Rails < 4
ActionDispatch::Http::UploadedFile.class_eval do
  unless instance_methods.include?(:eof?)
    def eof?
      @tempfile.eof?
    end
  end

  unless instance_methods.include?(:close)
    def close
      @tempfile.close
    end
  end
end