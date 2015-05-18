require 'spec_helper'

describe Notification do
  
  before do
    @group = create :group
    @member1 = create :user
    @member2 = create :user
    
    @group << @member1
    @group << @member2
    
    @post = @group.posts.create(author_user_id: @member1.id, sent_at: 1.minute.ago, subject: "Hello World", text: "Lorem ipsum dolor sit amet, consetetur, adipisci velit")
  end
  
  describe ".create_from_post" do
    subject { Notification.create_from_post(@post) }
    
    it { should be_kind_of Array }
    its(:count) { should == @group.members.count }
    its(:count) { should == 2 }
    
    describe ".last" do
      before { @notification = Notification.create_from_post(@post).last }
      subject { Notification.create_from_post(@post).last }
      
      it { should be_kind_of Notification }
      its(:recipient) { should == @member2 }
      its(:author) { should == @member1 }
      its(:reference) { should == @post }
      its(:reference_url) { should == @post.url }
      describe "#message" do
        subject { Notification.create_from_post(@post).last.message }
        describe "for the post subject being set separately" do
          it { should == "Hello World" }
        end
        describe "for the post subject being derived from the post text" do
          before { @post.update_attribute :subject, "Lorem ipsum dolor" }
          it { should == I18n.t(:has_posted_a_new_message) }
          describe "for the author being unknown (for example, for external authors)" do
            before { @post.update_attribute :author_user_id, nil }
            it { should == I18n.t(:a_new_message_has_been_posted) }
          end
        end
      end
      
      its(:text) { should == @post.text }
      its(:sent_at) { should == nil }
      its(:read_at) { should == nil }
    end
  end
  
  describe ".upcoming" do
    before { @notification1, @notification2 = Notification.create_from_post(@post) }
    subject { Notification.upcoming }
    it { should == [@notification1, @notification2] }
    it "should not include already-read notifications" do
      @notification1.update_attribute :read_at, Time.zone.now
      subject.should_not include @notification1
    end
    it "should not include notifications already sent via email" do
      @notification2.update_attribute :sent_at, Time.zone.now
      subject.should_not include @notification2
    end
  end
  
  describe ".upcoming_by_user" do
    before { Notification.create_from_post(@post) }
    subject { Notification.upcoming_by_user(@member1) }
    
    its(:count) { should == 1 }
    its('first.recipient_id') { should == @member1.id }
    it { should respond_to :deliver }
  end
  
  describe ".deliver" do
    before { Notification.create_from_post(@post) }
    subject { Notification.deliver }
    
    it "should send all upcoming notifications" do
      Notification.upcoming.count.should == 2
      subject
      Notification.upcoming.count.should == 0
    end
    
    describe "with already sent notifications" do
      before { @t = 1.hour.ago; Notification.first.update_attribute(:sent_at, @t) }
      it "should not deliver the same notification twice" do
        Notification.first.sent_at.should == @t
        subject
        Notification.first.sent_at.should == @t
      end
    end
    
  end
end
