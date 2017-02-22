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

  before { @group = create :group }

  describe "for users without account" do
    let(:user) { nil }
    let(:ability) { Ability.new(nil) }
    subject { ability }
    let(:the_user) { subject }

    describe "for regular @groups" do
      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end
    end

    describe "for the @group being an OfficerGroup" do
      before { @group.type = "OfficerGroup"; @group.save; @group = Group.find(@group.id) }

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
      end
    end

    describe "for the @group having a corporation" do
      before do
        @corporation = create :corporation_with_status_groups
        @corporation << @group
      end

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end
    end
  end


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
  describe "for users with account" do
    let(:user) { create(:user_with_account) }
    let(:ability) { Ability.new(user) }
    subject { ability }
    let(:the_user) { subject }

    describe "without the user being any member" do
      describe "for regular @groups" do
        describe "sender filter" do
          describe '(empty)' do
            before { @group.mailing_list_sender_filter = ""; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe '(nil)' do
            before { @group.mailing_list_sender_filter = nil; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe 'open' do
            before { @group.mailing_list_sender_filter = :open; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
          describe 'users_with_account' do
            before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
          describe 'corporation_members' do
            before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe 'group_members' do
            before { @group.mailing_list_sender_filter = :group_members; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe 'officers' do
            before { @group.mailing_list_sender_filter = :officers; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe 'group_officers' do
            before { @group.mailing_list_sender_filter = :group_officers; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe 'global_officers' do
            before { @group.mailing_list_sender_filter = :global_officers; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
        end
      end

      describe "for the @group being an OfficerGroup" do
        before { @group.type = "OfficerGroup"; @group.save; @group = Group.find(@group.id) }
      

        describe "sender filter" do
          describe '(empty)' do
            before { @group.mailing_list_sender_filter = ""; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
          describe '(nil)' do
            before { @group.mailing_list_sender_filter = nil; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
        end
      end

      describe "for the @group having a corporation" do
        before do
          @corporation = create :corporation_with_status_groups
          @corporation << @group
        end

        describe "sender filter" do
          describe '(empty)' do
            before { @group.mailing_list_sender_filter = ""; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
          describe '(nil)' do
            before { @group.mailing_list_sender_filter = nil; @group.save }
            he { should_not be_able_to :create_post_for, @group }
          end
        end
      end
    end

    describe "for corporation members" do
      before do
        @corporation = create :corporation_with_status_groups
        @corporation.status_groups.first.assign_user user
        @corporation << @group
      end

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end

      describe "for the @group being an OfficerGroup" do
        before { @group.type = "OfficerGroup"; @group.save; @group = Group.find(@group.id) }
      
        describe "sender filter" do
          describe '(empty)' do
            before { @group.mailing_list_sender_filter = ""; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
          describe '(nil)' do
            before { @group.mailing_list_sender_filter = nil; @group.save }
            he { should be_able_to :create_post_for, @group }
          end
        end
      end
    end

    describe "for @group members" do
      before { @group.assign_user user }

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end
    end

    describe "for officers of the @group" do
      before do
        @corporation = create :corporation_with_status_groups
        @corporation << @group
        @officer_group = @group.create_officer_group name: 'President'
        @officer_group.assign_user user
      end

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end
    end

    describe "for officers of another @group" do
      before do
        @other_group = create :group
        @officer_group = @other_group.create_officer_group name: 'President'
        @officer_group.assign_user user
      end

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should_not be_able_to :create_post_for, @group }
        end
      end
    end

    describe "for global officers" do
      # Currently, we've got an override in place (in the Ability model)
      # that allows global officers to post to any group, even if not
      # specified by the Group#mailing_list_sender_filter.

      before do
        @corporation = create :corporation_with_status_groups
        @corporation << @group

        @other_group = create :group
        @officer_group = @other_group.create_officer_group name: 'President'
        @officer_group.add_flag :global_officer
        @officer_group.assign_user user
      end

      describe "sender filter" do
        describe '(empty)' do
          before { @group.mailing_list_sender_filter = ""; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe '(nil)' do
          before { @group.mailing_list_sender_filter = nil; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'open' do
          before { @group.mailing_list_sender_filter = :open; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'users_with_account' do
          before { @group.mailing_list_sender_filter = :users_with_account; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'corporation_members' do
          before { @group.mailing_list_sender_filter = :corporation_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_members' do
          before { @group.mailing_list_sender_filter = :group_members; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'officers' do
          before { @group.mailing_list_sender_filter = :officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'group_officers' do
          before { @group.mailing_list_sender_filter = :group_officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
        describe 'global_officers' do
          before { @group.mailing_list_sender_filter = :global_officers; @group.save }
          he { should be_able_to :create_post_for, @group }
        end
      end
    end

  end
end