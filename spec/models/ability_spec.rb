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
  describe "for users with account" do
    let(:user) { create(:user_with_account) }
    let(:ability) { Ability.new(user) }
    subject { ability }
    let(:the_user) { subject }

    context "(posts and comments)" do
      context "when the user is a member of a group" do
        before { @group = create(:group); @group.assign_user(user, at: 1.month.ago) }
        he { should be_able_to :index_posts, @group }
        he { should be_able_to :create_post_for, @group }
        context "when there is a post in this group" do
          before do
            @post = @group.posts.create
            @post_attachment = @post.attachments.create
          end
          he { should be_able_to :read, @post }
          he { should be_able_to :read, @post_attachment }
          he { should be_able_to :download, @post_attachment }
          he { should be_able_to :create_comment_for, @post }
          context "when there is a comment for this post" do
            before { @comment = @post.comments.create }
            he { should be_able_to :read, @comment }
            he { should_not be_able_to :update, @comment }
          end
        end
      end
      context "when the user is no member of a group" do
        before { @group = create(:group) }
        he { should_not be_able_to :index_posts, @group }
        context "when there is a post in this group" do
          before do
            @post = @group.posts.create
            @post_attachment = @post.attachments.create
          end
          he { should_not be_able_to :read, @post }
          he { should_not be_able_to :read, @post_attachment }
          he { should_not be_able_to :download, @post_attachment }
          he { should_not be_able_to :create_comment_for, @post }
          context "when there is a comment for this post" do
            before { @comment = @post.comments.create }
            he { should_not be_able_to :read, @comment }
          end
          context "when the user is the author of a post (e.g. via email)" do
            before { @post.author = user; @post.save }
            he { should be_able_to :read, @post }
            he { should be_able_to :create_comment_for, @post }
          end
        end
      end

      context "(user profile)" do
        before do
          user.date_of_birth = 30.years.ago.to_date
          user.personal_title = "Dr."
          user.academic_degree = "Dr. rer. nat."
          user.save
        end

        he { should_not be_able_to :update, user.date_of_birth_field }
        he { should be_able_to :update, user.personal_title_field }
        he { should be_able_to :update, user.academic_degree_field }
      end
    end

    context "(mentions)" do
      context "when mentioned in a comment" do
        before do
          @group = create :group
          @post = @group.posts.create
          @post_attachment = @post.attachments.create
          @comment = @post.comments.create text: "This comment mentions @[[#{user.title}]] and, thereby, invites him to this post."
          Mention.create_multiple(create(:user), @comment, @comment.text)
        end
        specify { @group.members.should_not include user }
        he { should be_able_to :read, @post }
        he { should be_able_to :read, @comment }
        he { should be_able_to :create_comment_for, @post }
        he { should be_able_to :read, @post_attachment }
        he { should be_able_to :download, @post_attachment }
      end
      context "when mentioned in a post" do
        before do
          @group = create :group
          @post = @group.posts.create text: "This post mentions @[[#{user.title}]] and, thereby, invites him to this post."
          @post_attachment = @post.attachments.create
          Mention.create_multiple(create(:user), @post, @post.text)
        end
        specify { @group.members.should_not include user }
        he { should be_able_to :read, @post }
        he { should be_able_to :create_comment_for, @post }
        he { should be_able_to :read, @post_attachment }
        he { should be_able_to :download, @post_attachment }
      end
    end

    context "when the user is global admin" do
      before { user.global_admin = true }

      he "should not be able to destroy events that are older than 10 minutes" do
        @event = create :event, name: "Recent Event"
        @event.update_attribute :created_at, 11.minutes.ago

        the_user.should_not be_able_to :destroy, @event
      end

      he "should be able to destroy recently created pages" do
        @page = create :page, title: "New Page"

        the_user.should be_able_to :destroy, @page
      end
      he "should not be able to destroy pages that are older than 10 minutes" do
        @page = create :page, title: "Old Page"
        @page.update_attribute :created_at, 11.minutes.ago

        the_user.should_not be_able_to :destroy, @page
      end

      he "should be able to change the 'hidden' attribute of any user" do
        @other_user = create :user
        the_user.should be_able_to :change_hidden, @other_user
      end
    end

    context "when the user is a group admin" do
      before do
        @group = create :group
        @group.assign_admin user
        @other_user = create :user_with_account; @group << @other_user
        time_travel 2.seconds
      end

      he "should be able to update its profile fields" do
        @profile_field = @group.profile_fields.create(type: 'ProfileFieldTypes::Phone', value: '123')
        the_user.should be_able_to :update, @profile_field
      end

      he "should not be able to change the 'hidden' attribute of the group members" do
        the_user.should_not be_able_to :change_hidden, @other_user
      end
      he "should not be able to change his own 'hidden' attribute" do
        the_user.should_not be_able_to :change_hidden, user
      end

      he { should be_able_to :update, @other_user }
      he { should be_able_to :change_status, @other_user }
      he { should be_able_to :create_account_for, @other_user }
      he { should be_able_to :manage, @other_user.account }
    end

    context "when the user is officer of a group" do
      before do
        @group = create :group
        @officer_group = @group.create_officer_group(name: "Secretary")
        @officer_group.assign_user user
        @sub_group = @group.child_groups.create(name: "Sub Group")
        @sub_sub_group = @sub_group.child_groups.create(name: "Sub Sub Group")
        @parent_group = @group.parent_groups.create(name: "Parent Group")
        @unrelated_group = create :group
      end

      he "should not be able to update its profile fields" do
        @profile_field = @group.profile_fields.create(type: 'ProfileFieldTypes::Phone', value: '123')
        the_user.should_not be_able_to :update, @profile_field
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
        he "should be able to invite users to an event" do
          @event = @group.child_events.create
          the_user.should be_able_to :invite_to, @event
        end
        he { should_not be_able_to :create_event_for, @unrelated_group }
        he "should not be able to invite users to an event of an unrelated group" do
          @event = @unrelated_group.child_events.create
          the_user.should_not be_able_to :invite_to, @event
        end
      end
    end

    describe "when the user is a page admin" do
      before do
        @page = create :page
        @page.assign_admin user
      end

      he { should be_able_to :create_page_for, @page }
      he "should be able to destroy the sub-page" do
        @sub_page = @page.child_pages.create
        the_user.should be_able_to :destroy, @sub_page
      end
      he "should not be able to destroy the sub-page after 10 minutes" do
        @sub_page = @page.child_pages.create
        @sub_page.update_attribute :created_at, 11.minutes.ago
        the_user.should_not be_able_to :destroy, @sub_page
      end
    end

    describe "when the user is a page officer" do
      before do
        @page = create :page
        @secretary = @page.officers_parent.child_groups.create name: 'Secretary'
        @secretary << user
      end

      he { should be_able_to :create_page_for, @page }
      he "should be able to destroy the sub-page" do
        @sub_page = @page.child_pages.create
        the_user.should be_able_to :destroy, @sub_page
      end
      he "should not be able to destroy the sub-page after 10 minutes" do
        @sub_page = @page.child_pages.create
        @sub_page.update_attribute :created_at, 11.minutes.ago
        the_user.should_not be_able_to :destroy, @sub_page
      end
    end

    describe "when the user is contact person of an event" do
      before do
        @event = create :event
        @event.contact_people_group.assign_user user, at: 2.minutes.ago
      end
      he { should be_able_to :create_page_for, @event }

      describe "when he is author of a subpage of the event" do
        before do
          @page = @event.child_pages.create
          @page.author = user
          @page.save
        end
        he { should be_able_to :update, @page}
        he { should be_able_to :create_attachment_for, @page }

        describe "when he is author of an attachment" do
          before do
            @attachment = @page.attachments.create
            @attachment.author = user
            @attachment.save
          end
          he { should be_able_to :update, @attachment }
          he { should be_able_to :destroy, @attachment }

          describe "when the user is also a global officer (bug fix)" do
            before do
              @global_officers = create :group
              @global_officers.add_flag :global_officer
              @global_officers.assign_user user, at: 1.year.ago
            end
            let(:ability) { Ability.new(user, preview_as: 'global_officer') }

            he { should be_able_to :update, @attachment }
            he { should be_able_to :destroy, @attachment }
          end
        end

        describe "when he is not author of an attachment" do
          before do
            @attachment = @page.attachments.create
            @attachment.author = @other_user = create(:user)
            @attachment.save
          end
          he { should_not be_able_to :update, @attachment }
          he { should_not be_able_to :destroy, @attachment }
        end

      end
    end

    describe "when the user is a global officer" do
      before do
        @secretary = Group.everyone.create_officer_group name: 'Secretary'
        @secretary.add_flag :global_officer
        @secretary.assign_user user, at: 1.month.ago

        @any_group = create :group
      end
      he { should be_able_to :create_event_for, @any_group }

      he "should be able to post to any group" do
        @any_group = create :group

        the_user.should be_able_to :create_post, @any_group
        the_user.should be_able_to :create_post_for, @any_group
        the_user.should be_able_to :create_post_via_email, @any_group
        the_user.should be_able_to :force_post_notification, @any_group
      end

      describe "when he is contact person for an event" do
        before do
          @event = @any_group.child_events.create
          @event.contact_people << user
        end

        he { should be_able_to :update, @event }
        he { should be_able_to :invite_to, @event }
      end
    end

  end

  describe "for users without account" do
    let(:user) { create(:user) }
    let(:ability) { Ability.new(user) }
    subject { ability }
    let(:the_user) { subject }


    describe "(public pages)" do
      before do
        @root = Page.find_or_create_root
        @intranet_root = Page.find_or_create_intranet_root
        @some_internal_page = @intranet_root.child_pages.create title: 'This is internal.'
        @some_public_page = @root.child_pages.create title: 'This page is public.'
        Page.public_website_page_ids(true)  # reload cached ids
      end

      he "should be able to access the imprint page" do
        @page = create :page, title: "Imprint"
        @page.add_flag :imprint

        the_user.should be_able_to :read, @page
      end
      he { should be_able_to :read, Page.find_root }
      he { should_not be_able_to :read, Page.find_intranet_root }
      he { should be_able_to :read, @some_public_page }
      he { should_not be_able_to :read, @some_internal_page }
    end
  end
end