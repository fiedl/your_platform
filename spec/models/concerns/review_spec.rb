require 'spec_helper'

describe Review do

  describe "ProfileField" do

    before do
      @profile_field = ProfileField.create
    end

    describe "#needs_review?" do
      subject { @profile_field.needs_review? }
      describe "if set to true" do
        before { @profile_field.needs_review = true }
        it { should == true }
      end
      describe "if set to false" do
        before { @profile_field.needs_review = false }
        it { should == false }
      end
      describe "by default" do
        it { should == false }
      end
    end

    describe "#needs_review" do
      subject { @profile_field.needs_review }
      describe "if set to true" do
        before { @profile_field.needs_review = true }
        it { should == true }
      end
      describe "if set to false" do
        before { @profile_field.needs_review = false }
        it { should == false }
      end
      describe "by default" do
        it { should == false }
      end
    end

    describe "#needs_review = true" do
      subject { @profile_field.needs_review = true }
      it "should persist" do
        @profile_field.needs_review?.should == false
        subject
        @profile_field.reload.needs_review?.should == true
      end
    end

    describe "#needs_review = false" do
      before { @profile_field.needs_review = true}
      subject { @profile_field.needs_review = false }
      it "should persist" do
        @profile_field.needs_review?.should == true
        subject
        @profile_field.reload.needs_review?.should == false
      end
    end

    describe "#needs_review!" do
      subject { @profile_field.needs_review! }
      it "should set needs_review? to true" do
        @profile_field.needs_review?.should == false
        subject
        @profile_field.needs_review?.should == true
      end
      it "should persist" do
        @profile_field.needs_review?.should == false
        subject
        @profile_field.reload.needs_review?.should == true
      end
    end

    describe ".find_all_that_need_review" do
      before do
        @another_profile_field = ProfileField.create
        @profile_field.needs_review!
      end
      subject { ProfileField.find_all_that_need_review }
      it "should include the profile fields that need review" do
        subject.should include @profile_field
      end
      it "should not include the profile fields that do not need review" do
        subject.should_not include @another_profile_field
      end
    end

    describe ".find_all_that_need_review_by_profile_field_ids" do
      before do
        @another_profile_field = ProfileField.create
        @yet_another_profile_field = ProfileField.create
        @yet_another_profile_field.needs_review!
        @profile_field.needs_review!
        @ids = [@profile_field.id, @another_profile_field.id]
      end
      subject { ProfileField.find_all_that_need_review_by_profile_field_ids(@ids) }
      it "should include the profile fields that match the ids and need review" do
        subject.should include @profile_field
      end
      it "should not include the profile fields that do not need review" do
        subject.should_not include @another_profile_field
      end
      it "should not include the profile fields that do not match the ids" do
        subject.should_not include @yet_another_profile_field
      end
    end
  end

  describe "Membership" do
    subject { Membership.new }
    it { should respond_to :needs_review?, :needs_review!, :needs_review, :needs_review= }
  end

end