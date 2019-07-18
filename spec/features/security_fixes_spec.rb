require 'spec_helper'

feature "security fixes" do
  
  scenario "hacking files via the layout parameter should not be possible" do
    
    visit sign_in_path(:layout => '../../../config/database.yml')
    
    page.should have_no_text 'adapter:'
    page.should have_no_text 'mysql2'
    page.should have_no_text 'database'
    
  end
  
end