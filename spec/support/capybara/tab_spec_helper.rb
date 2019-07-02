module TabSpecHelper

  def click_tab(tab_name)
    within "#content .nav.tabs" do
      click_on tab_name
    end
  end

end