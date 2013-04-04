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
    plain_part_body = message.multipart? ? (message.text_part ? message.text_part.body.decoded : nil) : message.body.decoded
    html_part_body = message.html_part ? message.html_part.body.decoded : nil

    encoding = self.mail_encoding(message.html_part) if message.html_part

    body = html_part_body || plain_part_body
    body = body.force_encoding(encoding).encode('UTF-8') if encoding

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

  

end
