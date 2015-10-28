class BaseMailer < ActionMailer::Base
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
  default from: 'wingolfsplattform@wingolf.org'
  
end