FactoryGirl.define do

  ActionMailer::Base # required to have the Mail class available.

  # use `build(:mail_message_to_group)` instead of `create`.
  #
  factory :mail_message_to_group, :class => Mail do
  
    ignore do
      message "Date: Fri, 29 Mar 2013 23:55:00 +0100\n" +
        "From: foo@exampe.org\n" +
        "Subject: Testing Group Email Lists\n" +
        "To: test-group@example.com\n" +
        "This is a test email."
    end

    initialize_with { new(message) }
  end


end
