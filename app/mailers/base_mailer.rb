class BaseMailer < ActionMailer::Base
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
  default from: Setting.support_email

end