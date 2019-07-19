class IncomingMails::PostMail < IncomingMail

  def process(options = {})
    if authorized? and not in_reply_to_commentable

      post = recipient_group.posts.new
      post.incoming_mail_id = self.id

      if sender_user
        post.author_user_id = sender_user.id
      elsif sender_by_name
        post.author_user_id = sender_user.id
        post.external_author = sender_string
      else
        post.external_author = sender_string
      end

      post.sent_at = Time.zone.now
      post.subject = subject
      post.text = text_content
      post.message_id = message_id
      post.sent_via = destination
      post.save

      post.associate_deliveries

      #if self.has_attachments?
      #
      #  # I've copied this from https://github.com/ivaldi/brimir: ticket_mailer.rb
      #  self.attachments.each do |attachment|
      #    file = StringIO.new(attachment.decoded)
      #    # add needed fields for paperclip
      #    file.class.class_eval { attr_accessor :original_filename, :content_type }
      #    file.original_filename = attachment.filename
      #    file.content_type = attachment.mime_type
      #    post_attachment = post.attachments.create(file: file)
      #    post_attachment.save # FIXME do we need this because of paperclip?
      #  end
      #
      #  # We need to replace the inline-image sources in the message text:
      #  attachment_counter = 0
      #  post.text = post.text.gsub(/(<img [^>]* src=)("cid:[^>"]*")([^>]*>)/) do
      #    attachment_counter += 1
      #    attachment = post.attachments.find_by_type("image")[attachment_counter - 1]
      #    image_url = Rails.application.routes.url_helpers.root_url(Rails.application.config.action_mailer.default_url_options) + attachment.file.url
      #    "#{$1}\"#{image_url}\"#{$3}" # "<img src=...>" from regex
      #  end
      #  post.save
      #end

      [post]
    else
      []
    end
  end

end