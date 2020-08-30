require 'spec_helper'

describe UserSearch do

  describe "#search" do
    subject { User.search(query) }

    describe "(profile fields)" do
      before do
        @user = create :user_with_account
        @user.profile_fields.create type: "ProfileFields::About", label: "Working at", value: "Monster inc."
      end
      let(:query) { "Monster" }

      it "should find users with matching profile fields" do
        subject.should include @user
      end
      it "should set a search hint" do
        subject.first.search_hint.should include "Working at"
        subject.first.search_hint.should include "Monster inc."
      end
      it "should be chainable" do
        User.alive.search(query).should include @user
        User.alive.accessible_by(Ability.new(@user)).search(query).should include @user
        User.alive.search(query).first.search_hint.should include "Monster inc."
      end
      it "should return an Array rather than a relation" do
        # because otherwise, the search hint would be lost.
        subject.should be_kind_of Array
      end
    end


    # FIXME https://github.com/alexreisner/geocoder/issues/1181 ?

    #describe "(geo search)" do
    #  before do
    #    @user = create :user_with_account
    #    @user.profile_fields.create type: "ProfileFields::Address", label: "Working at", value: "Pariser Platz 1\n 10117 Berlin"
    #  end
    #  let(:query) { "Berlin 15km" }
    #
    #  it "should find users with matching address" do
    #    subject.should include @user
    #  end
    #  it "should be chainable" do
    #    User.alive.search(query).should include @user
    #    User.alive.accessible_by(Ability.new(@user)).search(query).should include @user
    #  end
    #end
  end

end