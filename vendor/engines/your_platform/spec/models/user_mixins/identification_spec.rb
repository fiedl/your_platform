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

  describe ".identify" do
    context "if only one user is matching" do
      it "should return the one matching user" do
        User.identify( "john.doe" ).should == @user1
        User.identify( "james.doe@example.com" ).should == @user2
        User.identify( "John Doe" ).should == @user1
      end
    end
    context "if multiple users are matching" do
      it "should return nil" do
        User.identify( "doe" ).should == nil
      end
    end
    context "if the last name is identical to the alias (bug fix)" do
      before do
        @user1.destroy # since only @user2 should be present for this test 
        @user2.update_attribute(:alias, 'doe')
      end
      specify "prerequisites" do
        @user2.alias.downcase.should == @user2.last_name.downcase
      end
      it "should return the one matching user" do
        User.identify( "doe" ).should == @user2
      end
    end
    context "for several users having the same last name and one of them having the last name as alias (bug fix)" do
      before do
        @user2.update_attribute(:alias, 'doe')
      end
      specify "prerequisistes" do
        @user2.last_name.downcase.should == @user2.alias.downcase
        @user2.last_name.downcase.should == @user1.last_name.downcase
      end
      it "should return the user identified by the alias" do
        User.identify("doe").should == @user2
      end
    end
  end



end
