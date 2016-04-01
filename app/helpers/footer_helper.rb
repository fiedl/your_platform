module FooterHelper
  def app_version_footer
    Rails.cache.fetch(['app_version_footer', AppVersion.commit_id], expires_in: 1.day) do
      ( "#{AppVersion.app_name}, " +
        link_to("Version #{AppVersion.version}", AppVersion.releases_url) +
        ", " +
        link_to("Commit #{AppVersion.short_commit_id}", AppVersion.github_commit_url) + 
        " | " +
        link_to("Changelog", AppVersion.changelog_url.gsub("deploy", "production")) +
        "<br />\n" +
        "YourPlatform-Engine, " +
        link_to("Changelog", AppVersion.your_platform_changelog_url)
      ).html_safe
    end
  end
end