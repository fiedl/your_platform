require 'spec_helper'

describe Notification do
  
  before do
    @group = create :group
    @member1 = create :user_with_account
    @member2 = create :user_with_account
    
    # TODO: REMOVE THE BETA
    User.all.each { |u| u.beta_tester = true }
    time_travel 2.seconds

    @group << @member1
    @group << @member2
    
    @post = @group.posts.create(author_user_id: @member1.id, sent_at: 1.minute.ago, subject: "Hello World", text: "Lorem ipsum dolor sit amet, consetetur, adipisci velit")
  end
  
  describe ".create_from_post" do
    subject { Notification.create_from_post(@post) }
    
    specify { @post.author.should == @member1 }
    
    it { should be_kind_of Array }
    its(:count) { should == @group.members.count - 1 }
    its(:count) { should == 1 }
    
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
          it { should == I18n.t(:has_posted_a_new_message, user_title: @member1.title, group_name: @group.name) }
          describe "for the author being unknown (for example, for external authors)" do
            before { @post.update_attribute :author_user_id, nil }
            it { should == I18n.t(:a_new_message_has_been_posted, group_name: @group.name) }
          end
        end
      end
      
      its(:text) { should == @post.text }
      its(:sent_at) { should == nil }
      its(:read_at) { should == nil }
    end
  end
  
  describe ".create_from_comment" do
    before do
      @comment = @post.comments.build text: "This is a comment."
      @comment.author = @member2
      @comment.save
    end
    subject { Notification.create_from_comment(@comment) }
    
    specify { @post.author.should == @member1 }
    specify { @comment.author.should == @member2 }
    
    it { should be_kind_of Array }
    its(:count) { should == 1 }
    its('first.recipient') { should == @member1 }
    its('first.author') { should == @member2 }
    its('first.reference') { should == @comment }
    its('first.message') { should == I18n.t(:has_commented_on, user_title: @member2.title, commentable_title: @post.title) }
    its('first.text') { should == "This is a comment." }
    its('first.sent_at') { should == nil }
  end
  
  describe ".upcoming" do
    before { @notifications = Notification.create_from_post(@post) }
    subject { Notification.upcoming }
    it { should == @notifications }
    it "should not include already-read notifications" do
      @notifications.first.update_attribute :read_at, Time.zone.now
      subject.should_not include @notifications.first
    end
    it "should not include notifications already sent via email" do
      @notifications.first.update_attribute :sent_at, Time.zone.now
      subject.should_not include @notifications.first
    end
  end
  
  describe ".due" do
    before do
      @notification = Notification.create_from_post(@post).first
      @user = @notification.recipient
    end
    subject { Notification.due }
    
    describe "when the user wants to be notified instantly" do
      before { @user.update_attribute(:notification_policy, :instantly) }
      it { should include @notification }
    end
    describe "when the user wants to be notified in letter bundles" do
      before { @user.update_attribute(:notification_policy, :letter_bundle) }
      it { should_not include @notification }
      describe "after 11 minutes" do
        before { time_travel 11.minutes }
        it { should include @notification }
      end
    end
    describe "when the user wants to be notified on a daily basis" do
      before { @user.update_attribute(:notification_policy, :daily) }
      describe "when it is before 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 14) }
        it { should_not include @notification }
      end
      describe "when it is after 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 19) }
        describe "when the notification has been created before 6 pm" do
          before { @notification.update_attribute(:created_at, Time.zone.now.change(hour: 15)) }
          it { should include @notification }
        end
        describe "when the notification has been created after 6 pm (send it tomorrow!)" do
          before { @notification.update_attribute(:created_at, Time.zone.now.change(hour: 18, minute: 30)) }
          it { should_not include @notification }
          describe "but when it is tomorrow, then" do
            before { Timecop.travel Date.tomorrow.to_datetime.change(hour: 19) }
            it { should include @notification }
          end
        end
      end
    end
  end
  
  describe ".upcoming_by_user" do
    before { Notification.create_from_post(@post) }
    subject { Notification.upcoming_by_user(@member2) }
    
    its(:count) { should == 1 }
    its('first.recipient_id') { should == @member2.id }
    it { should respond_to :deliver }
  end
  
  describe ".deliver" do
    before do 
      Notification.destroy_all
      Notification.create_from_post(@post)
      User.update_all notification_policy: 'instantly'
    end
    subject { Notification.deliver }
    
    it "should send all upcoming notifications" do
      Notification.upcoming.count.should == 1
      subject
      Notification.upcoming.count.should == 0
    end
    
    describe "with already sent notifications" do
      before { @t = 1.hour.ago; Notification.first.update_attribute(:sent_at, @t) }
      it "should not deliver the same notification twice" do
        Notification.first.sent_at.to_i.should == @t.to_i
        subject
        Notification.first.sent_at.to_i.should == @t.to_i
      end
    end
  end
  
  describe "#send_at" do
    before { @notification = Notification.create_from_post(@post).first }
    subject { @notification.send_at }

    specify { @notification.recipient.should == @member2 }
    it { should be_kind_of Time }

    describe "when the user wants to be notified :instantly" do
      before { @member2.update_attribute(:notification_policy, :instantly); @notification.reload }
      it { should < 1.minute.from_now }
    end
    
    describe "when the user wants to be notified in letter bundles" do
      before { @member2.update_attribute(:notification_policy, :letter_bundle); @notification.reload }
      it { should > 1.minute.from_now }
      it { should < 15.minutes.from_now }
    end
    
    describe "when the user wants to be notified on a daily basis" do
      before { @member2.update_attribute(:notification_policy, :daily); @notification.reload }
      describe "when it is before 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 14) }
        it { should == Date.today.to_datetime.change(hour: 18) }
      end
      describe "when it is after 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 19) }
        it { should == Date.tomorrow.to_datetime.change(hour: 18) }
      end
    end
    
    describe "when the user has not chosen a notification policy" do
      specify { @member2.read_attribute(:notification_policy).should == nil }
      describe "when it is before 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 14) }
        it { should == Date.today.to_datetime.change(hour: 18) }
      end
      describe "when it is after 18h" do
        before { Timecop.travel Time.zone.now.change(hour: 19) }
        it { should == Date.tomorrow.to_datetime.change(hour: 18) }
      end
    end
  end

end
