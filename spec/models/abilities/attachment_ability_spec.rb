require 'spec_helper'
require 'cancan/matchers'

describe Abilities::AttachmentAbility do
  describe "#rights_for_signed_in_users" do

    describe "(page attachments)" do
      specify "a signed-in user should be able to read a document published on a intranet page that does not belong to a specific group" do
        user = create :user_with_account
        page = create :page, title: "Satzungen"
        attachment = page.attachments.create title: "Bundessatzung"

        Ability.new(user).should be_able_to :read, attachment
        Ability.new(user).should be_able_to :download, attachment
      end

      specify "a signed-in user should not be able to read a document published on a page that belongs to a group the user is no member of" do
        user = create :user_with_account
        group = create :group
        page = group.child_pages.create title: "Interne Protokolle"
        attachment = page.attachments.create title: "Internes Protokoll"

        Ability.new(user).should_not be_able_to :read, attachment
        Ability.new(user).should_not be_able_to :download, attachment
      end
    end

    describe "(post attachments)" do
      specify "a signed-in user should be able to read a document posted within a group the user is member of" do
        user = create :user_with_account
        group = create :group
        group.assign_user user, at: 1.year.ago
        post = group.create_post published_at: 1.month.ago
        attachment = post.attachments.create title: "Posted document"

        Ability.new(user).should be_able_to :read, attachment
        Ability.new(user).should be_able_to :download, attachment
      end

      specify "a signed-in user should not be able to read a document posted within a group the user is no member of" do
        user = create :user_with_account
        group = create :group
        post = group.posts.create published_at: 1.month.ago
        attachment = post.attachments.create title: "Posted document"

        Ability.new(user).should_not be_able_to :read, attachment
        Ability.new(user).should_not be_able_to :download, attachment
      end
    end

  end
end