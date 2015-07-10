require 'spec_helper'

describe ReceivedPostMail do
  
  let(:sender_user) { create :user }
  let(:recipient_group) {
    group = create :group
    group.email = 'example-group@example.com'
    group.save
    group
  }
  let(:message) { 
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: Test Mail\n" + 
    "Message-ID: <beiNgai7OhZael0chach2xa9Kekirietiy6yuc3uu5Thah8I@example.com>\n\n" +
    "This is a simple text message."
  }
  let(:mail) { ReceivedPostMail.new(message) }
  
  let(:email_looped_message) {
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: Test Mail\n" + 
    "Message-ID: <uD3saic8Jiexah5aajee9ieba8aiGae6aaph7faelae7Mah7@example.com>\n\n" +
    "This is a simple text message.\n\n" + 
    "__________\n" +
    "Sent through mail group."
  }
    
  describe "#store_as_posts" do
    subject { mail.store_as_posts }
    
    its(:count) { should == 1 }
    describe "#first" do
      subject { mail.store_as_posts.first }
    
      it { should be_kind_of Post }
      its(:id) { should be_present }
      its(:group) { should == recipient_group }
      its(:author) { should == sender_user }
      its(:subject) { should == "Test Mail" }
      its(:text) { should == "This is a simple text message." }
      its(:content_type) { should == "text" }
      its(:message_id) { should be_present }
      
      describe "for an unknown sender" do
        let(:message) { 
          "From: Unknown Sender <unknown@example.com>\n" +
          "To: #{recipient_group.email}\n" +
          "Subject: Test Mail\n\n" +
          "This is a simple text message."
        }
        let(:mail) { ReceivedPostMail.new(message) }
    
        it "should store the author as string" do
          subject.author.should == "Unknown Sender <unknown@example.com>"
        end
      end
    end
    
    it "should not import the same email twice" do
      Post.destroy_all
      mail.store_as_posts
      Post.count.should == 1
      mail.store_as_posts
      Post.count.should == 1
    end
    
    it "should not import the same email twice if it came through an email loop with different message id" do
      # In this scenario, a recipient address redirects to the mail group address creating an email loop.
      # The mail system should prevent such email loops by comparing subject, sender and time.
      Post.destroy_all
      ReceivedPostMail.new(message).store_as_posts
      Post.count.should == 1
      ReceivedPostMail.new(email_looped_message).store_as_posts
      Post.count.should == 1
    end
  end

end