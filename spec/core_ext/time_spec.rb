require 'spec_helper'

describe Time do
  describe "(precision)" do

    before do
      @time = 2.hours.ago
      user = create :user
      group = create :group
      membership = Membership.create user: user, group: group, valid_from: @time
      @time_from_database = membership.reload.valid_from
      @rounded_time = @time.round(7)
    end

    describe "#==" do
      subject { @time == @time_from_database }
      it { binding.pry; should be true }
      specify { @time.should == @time_from_database }
      specify { @time.should == @rounded_time }
    end

    describe "#eql?" do
      subject { @time.eql? @time_from_database }
      it { should be true }
      specify { @time.should eql @time_from_database }
      specify { @time.should eql @rounded_time }
    end

  end
end