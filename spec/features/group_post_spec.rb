require 'spec_helper'

feature "Group Posts" do
  include SessionSteps

  background do
    #
    #  @super_group
    #       |-------- @group ------ @other_user
    #       |
    #     @officers ----- @user
    #
    @user = create :user_with_account
    @other_user = create :user_with_account
    @group = create :group
    @group << @other_user
    @parent_group = create :group
    @parent_group << @group
    @officers = @group.create_officer_group name: 'Officers'
    @officers << @user

    @random_message = "This is a random message: " + ('a'..'z').to_a.shuffle[0,8].join
  end

  describe "as officer:", :js do
    background { login(@user) }

    scenario 'Selecting conditions on recipients' do
      visit group_profile_path(@group)
      find('#new_post').click
      page.should have_text 'Anzahl der Empfänger: 2'

      find('label.constrain_validity_range').click
      # page.should have_text 'Anzahl der Empfänger: …'  # test is too fast.
      page.should have_text 'Anzahl der Empfänger: 2'

      fill_in :valid_from, with: I18n.localize('2025-12-01'.to_date)
      # page.should have_text 'Anzahl der Empfänger: …'  # test is too fast.
      page.should have_text 'Anzahl der Empfänger: 0'
    end
    scenario 'Sending a test message' do
      visit group_profile_path(@group)
      find('#new_post').click

      fill_in :message_text, with: @random_message
      find('#test_message').click

      page.should have_text 'Test-Nachricht wurde versandt.'
      page.should have_text 'Erneut zum Testen an meine eigene Adresse senden.'

      email_text = ''
      Timeout::timeout(15) do
        loop do
          email_text = ActionMailer::Base.deliveries.last.to_s
          break if email_text.include?(@random_message)
        end
      end
      email_text.should include @random_message
    end
    scenario 'Sending a group message' do
      visit group_profile_path(@group)
      find('#new_post').click

      fill_in :message_text, with: @random_message
      find('#confirm_message').click

      page.should have_text 'Nachricht wurde an 2 Empfänger versandt.'

      email_text = ''
      Timeout::timeout(20) do
        loop do
          email_text = ActionMailer::Base.deliveries.last.to_s
          break if email_text.include?(@random_message)
          sleep 0.3
        end
      end
      email_text.should include @random_message
    end
  end

  describe "as user that is member of the group:" do
    background { login(@other_user) }

    specify 'There should be a button to send a message.' do
      visit group_profile_path(@group)
      page.should have_selector '#new_post'
    end
  end

  describe "as unrelated user" do
    background { login(create(:user_with_account)) }

    specify 'There should be no button to send a message.' do
      visit group_profile_path(@group)
      page.should have_no_selector '#new_post'
    end
  end

end