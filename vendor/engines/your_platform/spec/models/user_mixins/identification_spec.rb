require 'spec_helper'

describe UserMixins::Identification do

  before do
    @user1 = create( :user, first_name: "John", last_name: "Doe", email: "john.doe@example.com", :alias => "john.doe" )
    @user2 = create( :user, first_name: "James", last_name: "Doe", email: "james.doe@example.com", :alias => "james.doe" )
  end

  describe ".attributes_used_for_identification" do
    subject { User.attributes_used_for_identification }
    it { should be_kind_of( Array ) }
    its( :first ) { should be_kind_of Symbol }
  end

  describe ".find_all_by_identification_string" do
    it "should return the matching users" do
      User.find_all_by_identification_string( "doe" ).should include( @user1, @user2 )
      User.find_all_by_identification_string( "john doe" ).should include( @user1 )
      User.find_all_by_identification_string( "james doe" ).should include( @user2 )
      User.find_all_by_identification_string( "john.doe" ).should include( @user1 )      
      User.find_all_by_identification_string( "John Doe" ).should include( @user1 )
      User.find_all_by_identification_string( "john.doe@example.com" ).should include( @user1 )
    end
  end

end
