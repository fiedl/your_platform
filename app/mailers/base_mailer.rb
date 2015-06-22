class BaseMailer < ActionMailer::Base
  helper MailerHelper
  helper MarkupHelper
  helper IconHelper
  helper MarkdownHelper
  
  helper ApplicationHelper
  default from: 'wingolfsplattform@wingolf.org'
  
end