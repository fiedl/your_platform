require 'spec_helper'

feature "best_in_place and hyperlinks" do
  include SessionSteps
  
  describe 'as admin', :js do
    background { login :admin }
  
    scenario 'clicking on a link inside a page body' do
      @other_page = create :page, title: 'hyperlink', content: 'this is the content behind the hyperlink.'
      @page = create :page, content: 'This is a page body with [[hyperlink]].'
      visit page_path @page
      
      click_on 'hyperlink'
      page.should have_text 'this is the content behind the hyperlink.'
    end
    
    scenario 'adding a link to a page body and then clicking it (bug fix)' do
      @other_page = create :page, title: 'hyperlink', content: 'this is the content behind the hyperlink.'
      @page = create :page, content: 'This is a page without hyperlink.'
      visit page_path @page
      
      within '.box.first' do
        click_on I18n.t :edit
        find('textarea').set 'This is a page body with [[hyperlink]].'
        click_on I18n.t :save
      end
      
      click_on 'hyperlink'
      page.should have_text 'this is the content behind the hyperlink.'
    end
    
    if ENV['CI'] != 'travis'  # they don't support uploads
      scenario 'clicking on an attachment link' do
        @page = create :page
        @attachment = create :image_attachment, title: 'New Attachment'
        @page.attachments << @attachment
        visit page_path @page
        
        click_on 'New Attachment'
        page.should have_no_text 'New Attachment'
        current_url.should include "attachments/#{@attachment.id}/image-upload.png"
      end
      
      scenario 'editing an attachment name in edit mode (bug fix)' do
        @page = create :page
        @attachment = create :image_attachment, title: 'New Attachment'
        @page.attachments << @attachment
        visit page_path @page
      
        within '.box.attachments' do
          click_on I18n.t :edit
          fill_in :title, with: 'The new attachment title'
          find('input[name=title]').click  # clicking in the text field should not redirect to the attachment url (bug fix)
        end
        
        wait_for_ajax; wait_for_ajax
        current_url.should_not include "attachments/#{@attachment.id}/image-upload.png"
      end
    end
    
  end
end