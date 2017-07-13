require 'spec_helper'

describe PagePublishing do
  let(:page) { create :page }

  subject { page }

  it { should be_unpublished }
  it { should be_draft }

  describe "after setting published_at" do
    before { page.update_attributes published_at: 1.day.ago }

    it { should be_published }
    it { should_not be_draft }
  end

end