require 'spec_helper'

feature "Attachments" do
  include SessionSteps

  before do
    @user = create :user_with_account
    @group = create :group
    @page = @group.child_pages.create
    @attachment = create :attachment, parent_id: @page.id, parent_type: 'Page'
  end

  specify "requirements" do
    @attachment.parent.should == @page
    @attachment.parent.group.should == @group
  end

  context "when the user has the right to download the attachment" do
    before do
      @group << @user
      login @user
    end
    scenario "download the attachment" do
      visit @attachment.file.url
      # Checking the pdf content will raise an error, "invalid byte sequence in UTF-8",
      # because this test tool can't read the pdf. But the error means, the pdf has
      # been opened successfully, i.e. no "access denied".
      #
      expect { page.has_no_content? I18n.t(:access_denied) }.to raise_error(ArgumentError)
    end
  end

  context "when the user has no right to download the attachment" do
    before do
      login @user
    end
    scenario "download the attachment", :js do

      # FIXME: This should not be neccessary. Above (requirements), this succeeds.
      wait_until { @attachment.parent.uncached(:group); @attachment.parent.group == @group }

      visit @attachment.file.url
      page.should have_content I18n.t(:access_denied)
    end
  end

end
