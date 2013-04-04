class Post < ActiveRecord::Base
  attr_accessible :author_user_id, :external_author, :group_id, :sent_at, :sticky, :subject, :text
  belongs_to :group
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'

  # This creates a new post from the information given in the `message`.
  # `message` is a `Mail::Message` object (from `ActionMailer::Base`.
  # See spec/factories/mail_message.rb.
  #
  def self.create_from_message(message)

    # http://stackoverflow.com/questions/4868205
    part_to_use = message.html_part || message.text_part || message
    encoding = part_to_use.content_type_parameters['charset'] if part_to_use.content_type_parameters
    body = part_to_use.body.decoded
    body = body.force_encoding(encoding).encode('UTF-8') if encoding

    # extract the content of the body tag if necessary
    if body.include?('<body')
      doc = Nokogiri::HTML( body )
      body = doc.xpath( '//body' ).first.inner_html
    end

    new_post = self.create(subject: message.subject, text: body, sent_at: message.date)
    new_post.author = message.from.first
    new_post.set_group_by_email_address(message.to.first)
    new_post.save
    return new_post
  end

  # TODO: create_multiple_from_message

  # This allows to set the author either as email or as email string.
  #
  def author=(author)
    if author.kind_of? User
      super(author)
    elsif author.kind_of? String
      users_by_email = User.find_all_by_email(author) 
      user_by_email = users_by_email.first if users_by_email.count == 1
      if user_by_email
        super(user_by_email)
      else
        self.external_author = author
      end
    end
  end
  def author
    super || external_author
  end

  # This sets the group this message belongs to, identifying the group by its email token.
  #
  def set_group_by_email_address(email_address)
    token = email_address.split("@").first
    groups = Group.select { |group| group.name && group.name.parameterize == token } 
    # TODO Make this efficient, e.g. by email_token attribute
    self.group = groups.first if groups.count == 1
  end

  # In order to do the encoding conversion properly,
  # we have to find out the former encoding from the mail header.
  # 
  # parameter: Mail object
  # #<Mail::Part:-570274288, Multipart: false, Headers: <Content-Type: text/html; charset=windows-1252>, 
  #   <Content-Transfer-Encoding: quoted-printable>>
  # 
  def self.mail_encoding(mail)
    mail.inspect.to_s.scan(/.charset=(.*)>./)[0][0].split(">").first if mail
  end

  
  # This returns the text attribute, i.e. the message body, without html tags,
  # which could be used in block quotes, where only an excerpt of the message
  # is shown. (Use this to avoid opened but not closed html tags.)
  #
  def text_without_html_tags
    # http://stackoverflow.com/questions/7414267/strip-html-from-string-ruby-on-rails
    HTML::FullSanitizer.new.sanitize(self.text)
  end


  # Delivering Post as Email to All Group Members
  # ==========================================================================================

  # Each post may be delivered to all group members via email. ("Group Mail Feature").
  # This method returns the message to deliver to the group members.
  # This is done separately (i.e. one user at a time) in order to (a) not reveal the 
  # email addresses, and (b) avoid being caught by a spam filter.
  #
  # Calling this method will produce, *not deliver* the mail messages.
  # 
  def messages_to_deliver_to_mailing_list_members
    self.group.descendant_users.collect do |user|
      
    end
  end

  # This method returns the modified subject, which is used by the Group Mail Feature.
  # Give a post subject 'My Fancy Subject" and the post's group's name being "Test Group",
  # this mehtod returns "[Test Group] My Fancy Subject". 
  #
  # If the subject already contains the prefix, like in "Re: [Test Group] My Fancy Subject", 
  # of cause, the prefix isn't added, twice.
  #
  def modified_subject
    prefix = "[#{self.group.name}] "
    if self.subject.include? prefix
      return subject
    else
      return prefix + subject
    end
  end

  # This method returns a mail footer, which may be added to the messages delivered via
  # email. The footer contains, e.g. a link to the group's site.
  #
  def mailing_list_footer
    "\n\n\n" + 
      "_____________________________________\n" +
      I18n.t(:this_message_has_been_deliverd_through_mailing_list, group_name: self.group.name ) + "\n" +
      self.group.url + "\n"
  end

end
