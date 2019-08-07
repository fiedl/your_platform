require 'devise'

# Patch the devise mailer that, for example, sends password-recovery emails
# to match our spam-protection-conformity requirements.
#
# Address headers need to be like
#
#    "Foo" <bar@example.com>
#
# rather than just
#
#    bar@example.com
#
# in order not to be rejected with "SMTP 554 5.7.0 Reject".
#
# https://github.com/plataformatec/devise
# https://trello.com/c/s94OXzul/1371-e-mails-554-570-reject
# https://stackoverflow.com/q/57173606/2066546
#
module DeviseMailersHelpersExptensions
  def headers_for(action, opts)
    headers = super

    headers[:to] = "\"#{resource.user.title}\" <#{resource.email}>"
    headers[:from] = BaseMailer.default_params[:from]
    headers[:reply_to] = BaseMailer.default_params[:from]

    return headers
  end
end

module Devise::Mailers::Helpers
  prepend DeviseMailersHelpersExptensions
end