require 'spec_helper'

describe Mention do
  before do
    @sender_user = create :user
    @recipient_user = create :user
    
    @group = create :group
    @post = @group.posts.create text: "This is a test post in the #{@group.name} group."
    
    @comment = @post.comments.create text: "I'd like to invite @[[#{@recipient_user.title}]] to our conersation."
  end

  describe ".create_multiple(...).first" do
    subject { Mention.create_multiple(@sender_user, @comment, @comment.text).first }
    
    its(:who) { should == @sender_user }
    its(:whom) { should == @recipient_user }
    its(:reference) { should == @comment }
    its(:reference_title) { should == @post.title }
    
    its('who.mentions.count') { should == 0 }
    its('whom.mentions.count') { should == 1 }
    its('reference.mentions.count') { should == 1 }
  end
  
  describe ".create_multiple" do
    before do
      @other_recipient_user = create :user
      @comment.update_attributes text: "Inviting @[[#{@recipient_user.title}]] and @[[#{@other_recipient_user.title}]]."
      @comment.reload
    end
    subject { Mention.create_multiple(@sender_user, @comment, @comment.text) }
    
    specify "prelims" do
      @comment.text.should include @recipient_user.title
      @comment.text.should include @other_recipient_user.title
    end
    
    its(:count) { should == 2 }
    its('first.whom') { should == @recipient_user }
    its('second.whom') { should == @other_recipient_user }
  end

end
