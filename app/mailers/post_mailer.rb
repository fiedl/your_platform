class PostMailer < BaseMailer

  def post_email(post:, recipient:)
    @subject = post.title
    @post_url = post_url(post)
    @body = post.text.html_safe
    @author = post.author
    @recipient = recipient
    @sender_avatar_url = avatar_url_for(post.author)
    @recipient_groups = post.parent_groups

    post.attachments.each do |attachment|
      attachments[attachment.filename] = File.read(attachment.file.path)
    end

    message = mail subject: @subject

    message.from = "#{post.author.title} <#{post.author.email}>"
    message.reply_to = "#{post.author.title} <#{post.author.email}>"
    message.return_path = BaseMailer.delivery_errors_address
    message.sender = BaseMailer.technical_sender
    message.to = post.parent_groups.collect { |group|
      address = group.mailing_lists.first.try(:value)
      address ||= "#{group.title.parameterize}-#{group.id}.noreply@#{AppVersion.domain}"
      "#{group.name_with_corporation} <#{address}>"
    }.join(", ")
    message.cc = "#{post.author.title} <#{post.author.email}>"
    message.smtp_envelope_to = recipient.email || raise('no delivery address!')
    message.date = post.sent_at

    return message
  end

end
