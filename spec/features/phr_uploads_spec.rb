require 'spec_helper'

feature "PhR Uploads" do
  include SessionSteps
  
  background do
    @everyone = Group.everyone
    @intranet_root = Page.intranet_root
    @vaw = @intranet_root.child_pages.create title: 'VAW'
    @phr = @vaw.child_groups.create name: 'PhR'
    @phr_documents = @phr.child_pages.create title: 'PhR Documents', content: 'secret content'
    
    @member = create :user_with_account; @phr.assign_user @member, at: 2.months.ago
    @other_member = create :user_with_account; @phr.assign_user @other_member, at: 2.months.ago
    @non_member = create :user_with_account
    
    @paper_warriers = @phr.officers_parent.child_groups.create name: 'Paper Warrier'
    @paper_warriers.assign_user @member, at: 2.months.ago
    @paper_warriers.assign_user @other_member, at: 2.months.ago
  end
  
  specify 'prelims' do
    @paper_warriers.members.should include @member, @other_member
    @phr.officers.should include @member, @other_member
  end
  
  scenario 'non-members have no access to the documents' do
    login @non_member
    
    visit root_path
    within('.vertical_menu') { click_on 'VAW' }
    within('.vertical_menu') { click_on 'PhR' }
    page.should have_text @member.last_name
    page.should have_text @other_member.last_name
    page.should have_no_text @phr_documents.title
    
    visit page_path(@phr_documents)
    page.should have_text @non_member.title # in the login bar
    page.should have_no_text 'secret content'
  end
  
  scenario 'non-members do not see the documents in the what_is_new box' do
    login @non_member
    
    visit root_path
    page.should have_selector '.box.what_is_new'
    within '.box.what_is_new' do
      page.should have_text 'VAW'
      page.should have_no_text @phr_documents.title
    end
  end

  scenario 'non-members have access to the member list' do
    login @non_member
    
    visit root_path
    within('.vertical_menu') { click_on 'VAW' }
    within('.vertical_menu') { click_on 'PhR' }
    page.should have_text I18n.t :members
    page.should have_text @member.last_name
    page.should have_text @member.first_name
    page.should have_text @member.aktivitaetszahl
    page.should have_text @other_member.last_name
    page.should have_text @other_member.first_name
    page.should have_text @other_member.aktivitaetszahl
  end
  
  scenario 'members have access to the documents' do
    login @member
    
    visit root_path
    within('.vertical_menu') { click_on 'VAW' }
    within('.vertical_menu') { click_on 'PhR' }
    page.should have_text @member.last_name
    page.should have_text @other_member.last_name
    page.should have_text @phr_documents.title
    
    within('.vertical_menu') { click_on 'PhR Documents' }
    page.should have_text 'secret content'
        
    visit page_path(@phr_documents)
    page.should have_text 'secret content'
  end

  if ENV['CI'] != 'travis'  # they do not support uploads
    scenario 'members can upload documents', :js do
      login @member
      
      visit page_path(@phr_documents)
      page.should have_text 'secret content'
      
      within '.box.attachments' do
        click_on I18n.t :edit
        attach_file :attachment_file, File.expand_path(File.join(__FILE__, '../../support/uploads/pdf-upload.pdf'))
      end
      
      page.should have_text 'pdf-upload.pdf'
      page.should have_no_text 'Anhang wird auf dem Server verarbeitet.'
    
      page.should have_text 'pdf-upload.pdf'
      page.should have_text '200 KB'
    end
    
    # scenario 'members can delete their uploaded documents', :js do
    #   login @member
    #   
    #   visit page_path(@phr_documents)
    #   within '.box.attachments' do
    #     click_on I18n.t :edit
    #     attach_file :attachment_file, File.expand_path(File.join(__FILE__, '../../support/uploads/pdf-upload.pdf'))
    #   end
    #   page.should have_text 'pdf-upload.pdf'
    #   page.should have_text '200 KB'
    #   
    #   pending "need to fix the remove button!"
    #   
    #   # within '.box.attachments' do
    #   #   page.should have_selector '.remove_button', visible: true
    #   #   find('.remove_button').click
    #   #   page.should have_no_text 'pdf-upload.pdf'
    #   # end
    # end
  end
  
  scenario 'members can create blog posts'
  
end