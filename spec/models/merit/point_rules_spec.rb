# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do
    @user = create( :user )
    @user.save
    @points = @user.points
  end

  subject { @user }

  # Validation
  # ==========================================================================================

  it { should be_valid }


  # Basic Properties
  # ==========================================================================================

  describe "events#join" do
    subject { @user }
    [ :first_name, :last_name, :alias, :email, :create_account, :female, :add_to_group ].each do |attr|
      it { should respond_to( attr ) }
      it { should respond_to( "#{attr}=".to_sym ) }
    end
  end

  describe "events#join" do
    subject { @user.join(@event); time_travel(2.seconds) }
    describe "(joining an event)" do
      before { @event = create(:event); subject }
      specify { @event.attendees.should include @user}
      specify { @event.attendees_group.members.should include @user }
      specify "the user should have earned points" do
        @user.points > @points
      end
    end

  end

end
