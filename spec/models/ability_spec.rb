require 'spec_helper'
require 'cancan/matchers'

# In order to call the user "he" rather than "it", 
# we have to define an alias here.
# 
# http://stackoverflow.com/questions/12317558/alias-it-in-rspec
#
RSpec.configure do |c|
  c.alias_example_to :he
end

describe Ability do
  
  # I'm sorry. I do have problems with cancan's terminology, here.
  # For me, the User can do something, i.e. I would ask 
  #
  #   @user.can? :manage, @page
  #
  # But for cancan, it's 
  #
  #   Ability.new(@user).can? :manage, @page
  #
  # That is why I let(:the_user) be the ability.
  # Also note, "he" refers to the regular "it" call.
  # I just like to call the user "he" rather than "it".
  #  
  let(:user) { create(:user_with_account) }
  let(:ability) { Ability.new(user) }
  subject { ability }
  let(:the_user) { subject }
  
  context "when the user is global admin" do
    before { user.global_admin = true }
    
    he "should not be able to destroy events that are older than 10 minutes" do
      @event = create :event, name: "Recent Event"
      @event.update_attribute :created_at, 11.minutes.ago
      
      the_user.should_not be_able_to :destroy, @event
    end
  end
  
  context "when the user is officer of a group" do
    before do
      @group = create :group
      @officer_group = @group.officers_groups.create(name: "Secretary")
      @officer_group.assign_user user
      @sub_group = @group.child_groups.create(name: "Sub Group")
      @sub_sub_group = @sub_group.child_groups.create(name: "Sub Sub Group")
      @parent_group = @group.parent_groups.create(name: "Parent Group")
      @unrelated_group = create :group
    end

    describe "(events)" do
      he "should be able to create an event in his group" do
        the_user.should be_able_to :create_event, @group
      end
      he "should be able to update events in his group" do
        @event = @group.child_events.create
        the_user.should be_able_to :update, @event
      end
      he "should be able to create events in subgroups of his group" do
        the_user.should be_able_to :create_event, @sub_group
      end
      he "should be able to update events in subgroups of his group" do
        @event = @sub_group.child_events.create
        the_user.should be_able_to :update, @event
      end
      he "should be able to update events in sub sub groups of his group" do
        @event = @sub_sub_group.child_events.create
        the_user.should be_able_to :update, @event
      end
      he "should be able to update the contact people of an event" do
        @event = @group.child_events.create
        the_user.should be_able_to :update, @event.contact_people_group
      end
      he "should be able to destroy just created events in his domain" do
        @event = @group.child_events.create name: "Special Event"
        
        user.should be_in @group.officers_of_self_and_ancestors
        the_user.should be_able_to :destroy, @event
      end
      he "should not be able to destroy events that are older than 10 minutes" do
        @event = @group.child_events.create name: "Recent Event"
        @event.update_attribute :created_at, 11.minutes.ago
        
        the_user.should_not be_able_to :destroy, @event
      end
    end
  end
  
end