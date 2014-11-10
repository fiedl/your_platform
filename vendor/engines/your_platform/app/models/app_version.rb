class AppVersion
  
  def self.last_tag
    `git describe --abbrev=0 --tags`.strip
  end
  
  def self.version
    last_tag.gsub("v", "")
  end
  
  def self.commit_id
    `git rev-parse HEAD`.strip
  end
  
  def self.short_commit_id
    `git rev-parse --short HEAD`.strip
  end
  
  # Returns something like:
  # `git@github.com:fiedl/wingolfsplattform.git`
  def self.git_remote_url
    `git config --get remote.origin.url`.strip
  end
  
  def self.github_repo_url
    git_remote_url.gsub(":", "/").gsub("git@", "https://").gsub(/.git$/, "")
  end

  def self.github_commit_url
    "#{github_repo_url}/commit/#{commit_id}"
  end
  
  def self.changelog_url
    "#{github_repo_url}/commits/#{branch}"
  end
  
  def self.releases_url
    "#{github_repo_url}/releases"
  end
  
  def self.branch
    `git rev-parse --abbrev-ref HEAD`.strip
  end
  
  def self.app_name
    Setting.app_name || Rails.application.class.parent_name
  end

end