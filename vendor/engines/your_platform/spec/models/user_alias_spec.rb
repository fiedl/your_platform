require 'spec_helper'

describe UserAlias do

  describe ".taken?(alias)" do
    subject { UserAlias.taken?("j.doe") }
    describe "for the alias not being taken" do
      it { should be_false }
    end
    describe "for the alias being taken" do
      before { @user = create(:user, :alias => "j.doe" ) }
      it { should be_true }
      it { should == @user }
    end
  end

  describe "#taken?" do
    subject { UserAlias.new("foo").taken? }
    describe "for the alias not being taken" do
      it { should == false }
    end
    describe "for the alias being taken" do
      before { @user = create(:user, :alias => "foo") }
      it { should be_true }
      it { should == @user }
    end
  end

  describe ".generate_for(user)" do
    before do
      @user = create(:user, first_name: "John", last_name: "Doe")
    end
    subject { UserAlias.generate_for(@user) }
    describe "for no other user with the same last name existing" do
      it { should == "doe" }
    end
    describe "for a user with the same last name existing" do
      before { create(:user, first_name: "Otto", last_name: "Doe") }
      it { should == "j.doe" }
    end
    describe "for a user with the same last name and a first name with the same initial existing" do
      before { create(:user, first_name: "Jane", last_name: "Doe") }
      it { should == "john.doe" }
    end
    describe "for a user with the same first and last names existing" do
      before { create(:user, first_name: "John", last_name: "Doe", :alias => "some_other_alias") }
      describe "for the user having a date of birth given" do
        before { @user.date_of_birth = "1986-01-01".to_date }
        it { should == "john.doe.1986" }
      end
      describe "for the user having no date of birth given" do
        it { should == nil }
      end
    end
  end

end
