require 'spec_helper'

describe PageVisibility do
  let(:page) { create :page }

  subject { page }

  describe "for the page author" do
    let(:author_user) { create :user }
    before { page.author = author_user; page.save }

    it { should be_visible_to author_user }

    describe "after archiving the page" do
      before { page.update_attributes archived_at: 1.hour.ago }

      it { should_not be_visible_to author_user }
    end

    describe "when simulating how other users see the page" do
      it { should_not be_visible_to author_user, preview_as: :user}
    end
  end

  describe "for another user" do
    let(:other_user) { create :user }

    it { should_not be_visible_to other_user }

    describe "after publishing the page" do
      before { page.update_attributes published_at: 1.day.ago }

      it { should be_visible_to other_user }

      describe "after archiving the page" do
        before { page.update_attributes archived_at: 1.hour.ago }

        it { should_not be_visible_to other_user }
      end
    end
  end

end