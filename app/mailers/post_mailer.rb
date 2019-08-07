class PostMailer < BaseMailer

  def post_email(text, recipients, subject, sender, group, post)
    @text = text
    @subject = subject.gsub(/\[.*\]/, '')
    @group = group
    @post = post

    # ## `to` vs. `smtp_envelope_to`.
    #
    # In emails as in physical mails (paper sheet in paper envelope),
    # the recipient on the envelope may differ from the recipient on
    # the letter sheet itself.
    #
    # As the mailman would only consider the envelope's recipient,
    # so do mail servers.
    #
    # That means, one actually can tell the smtp service to send an
    # email to a recipient different than the one listed in the `To:`
    # field of the email header.
    #
    # This feature is used for our email lists: The group email address
    # is shown in the `to` field, but the email is really sent to the
    # individual group members (`smtp_envelope_to`).
    #
    # Attention! The `to` fields may be set to a name plus email address
    # like "John Doe <doe@example.com>", but the `smtp_envelope_to` fields have
    # to be valid email addresses and nothing more, i.e. "doe@example.com".
    #
    # See also: http://stackoverflow.com/a/15851602/2066546
    #
    @to_field = "\"#{@group.title}\" <#{@group.email}>"
    @smtp_envelope_to_field = recipients.collect { |user| user.email }

    if sender.kind_of? User
      # If the sender is recognized by the system, replies generate comments.
      @from_field = "\"#{sender.title}\" <#{sender.email}>"
      @reply_to = ReceivedCommentMail.generate_address(recipients.first, post) if post.try(:id)
      @show_delivery_report_link = ([sender.id] == recipients.map(&:id))
    else
      @from_field = sender.to_s
      @reply_to = @from_field
    end

    I18n.with_locale(recipients.first.try(:locale) || I18n.default_locale) do
      message = mail(
        to: @to_field, from: @from_field, subject: subject,
        reply_to: @reply_to
      )
      message.smtp_envelope_to = @smtp_envelope_to_field
    end
    return message
  end

end
