class BaseMailer < ActionMailer::Base
  helper :logo

  helper LogoHelper
  helper MailerHelper
  helper MarkupHelper
  helper IconHelper
  helper MarkdownHelper
  helper MentionsHelper
  helper QuickLinkHelper
  helper EmojiHelper
  helper YouTubeHelper
  helper ActionView::Helpers::SanitizeHelper

  helper ApplicationHelper
  default from: "\"#{AppVersion.app_name}\" <#{Setting.support_email}>"

  include PrivateViews

  def self.delivery_errors_address
    "delivery-errors@#{AppVersion.email_domain}"
  end

  private

  private

  def avatar_url_for(user)
    url = user.avatar_path
    url = "https://#{AppVersion.domain}#{url}" if url.start_with? "/"
    url
  end

end