class Post < ActiveRecord::Base
  attr_accessible :author_user_id, :external_author, :group_id, :sent_at, :sticky, :subject, :text
  belongs_to :group
  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'

  # This creates a new post from the information given in the `message`.
  # `message` is a `Mail::Message` object (from `ActionMailer::Base`.
  # See spec/factories/mail_message.rb.
  #
  def self.create_from_message(message)
    p "================================================================================"
    p message.text_part
    p "--------------------------------------------------------------------------------"
    p message.html_part
    p "--------------------------------------------------------------------------------"

    new_post = self.create(subject: message.subject, text: message.body.decoded, sent_at: message.date)
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

end
