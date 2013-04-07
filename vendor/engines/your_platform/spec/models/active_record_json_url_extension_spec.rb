require 'spec_helper'

describe ActiveRecordJsonUrlExtension do

  # This extension applies to all ActiveRecord::Base models.
  # Therefore, we just pick the User class for testing.
  #
  # Warning! This extension does not meet the MVC model.
  # But the extension is needed in order to provide urls via 
  # the JSON interface, automatically and throughout associations.
  # If there's a better way to do this, please help!!
  #

  before do
    @user = create( :user )
  end

  include Rails.application.routes.url_helpers
  include ActionDispatch::Routing::UrlFor

  def url_options
    options = Rails.application.config.action_mailer.default_url_options
    raise 'there went something wrong. These options should not be empty: ' + options.to_s if options == {} or not options.present?
    return options
  end

  describe "#url" do
    subject { @user.url }
    it "should not raise an error" do
      expect { subject }.not_to raise_error
    end
    it "should be an url" do
      subject.should include "http"
      subject.should include "://"
    end
    it "should return the url_for this object" do
      subject.should == url_for( @user )
    end
  end

  describe "#serializable_hash" do
    subject { @user.serializable_hash }
    it { should be_kind_of Hash }
    it "should include the url" do
      subject[ :url ].should == @user.url
    end

    describe "for associated objects" do
      before do
        @group = create( :group )
        @group.assign_user @user
      end
      subject { @user.serializable_hash( :include => :parent_groups ) }
      it "should include the urls of the associated objects" do
        subject[ :parent_groups ][ 0 ][ :url ].should == @group.url
      end
      
      describe "with other methods being included as well" do
        subject { @user.serializable_hash( :include => { :parent_groups => { :methods => :title } } ) }
        it "should include the other methods" do
          subject[ :parent_groups ][ 0 ][ :title ].should == @group.title
        end
        it "should include the url" do
          subject[ :parent_groups ][ 0 ][ :url ].should == @group.url
        end
      end
    end
  end

  describe "to_json" do
    subject { @user.to_json }
    it { should be_kind_of String }
    it "should include the url" do
      json_string = { url: @user.url }.to_json.gsub( "{", "" ).gsub( "}", "" )
      subject.should include json_string
    end
  end

end
