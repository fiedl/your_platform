FactoryGirl.define do

  ActionMailer::Base # required to have the Mail class available.

  # use `build(:mail_message_to_group)` instead of `create`.
  #
  factory :mail_message_to_group, :class => Mail do
  
    transient do
      message "Date: Fri, 29 Mar 2013 23:55:00 +0100\n" +
        "From: foo@exampe.org\n" +
        "Subject: Testing Group Email Lists\n" +
        "To: test-group@example.com\n" +
        "This is a test email."
    end

    initialize_with { new(message) }
  end

  factory :html_mail_message, :class => Mail do
    
    transient do
      email_file_name = File.join(File.dirname(__FILE__), './html_email.eml')
      message File.open(email_file_name, "r").read
    end

    initialize_with { new(message) }
  end

end
