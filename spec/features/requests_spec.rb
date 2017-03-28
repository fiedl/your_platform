require 'spec_helper'

feature "Keeping track of requests for statistical analysis" do
  include SessionSteps

  scenario "visiting a page" do
    @page = create :page
    @user = create :user_with_account
    login @user

    expect {
      visit page_path(@page)
    }.to change { Request.count }.by(1)

    @request = Request.last

    @request.user_id.should == @user.id
    @request.user.should == @user
    @request.ip.should be_present
    @request.navable.should == @page

    # But the user_id should not be stored
    # in the database. It only lives in the
    # temporary cache.
    #
    (Request.pluck(:user_id) - [nil]).count.should == 0
  end

end